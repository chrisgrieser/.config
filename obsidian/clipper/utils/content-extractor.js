var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { extractReadabilityContent, createMarkdownContent } from './markdown-converter';
import { sanitizeFileName } from './obsidian-note-creator';
import { applyFilters } from './filters';
import dayjs from 'dayjs';
function processVariable(match, variables) {
    return __awaiter(this, void 0, void 0, function* () {
        const [, fullVariableName] = match.match(/{{(.*?)}}/) || [];
        const [variableName, ...filterParts] = fullVariableName.split('|');
        const filtersString = filterParts.join('|');
        const value = variables[`{{${variableName}}}`] || '';
        const filterNames = filtersString.split('|').filter(Boolean);
        const result = applyFilters(value, filterNames);
        return result;
    });
}
function processSelector(tabId, match) {
    return __awaiter(this, void 0, void 0, function* () {
        const selectorRegex = /{{selector:(.*?)(?:\|(.*?))?}}/;
        const matches = match.match(selectorRegex);
        if (!matches) {
            console.error('Invalid selector format:', match);
            return match;
        }
        const [, selector, filtersString] = matches;
        const { content } = yield extractContentBySelector(tabId, selector);
        // Convert content to string if it's an array
        const contentString = Array.isArray(content) ? JSON.stringify(content) : content;
        if (filtersString) {
            const filterNames = filtersString.split('|').map(f => f.trim());
            return applyFilters(contentString, filterNames);
        }
        return contentString;
    });
}
function processSchema(match, variables) {
    return __awaiter(this, void 0, void 0, function* () {
        const [, fullSchemaKey] = match.match(/{{schema:(.*?)}}/) || [];
        const [schemaKey, ...filterParts] = fullSchemaKey.split('|');
        const filtersString = filterParts.join('|');
        let schemaValue = '';
        // Check if we're dealing with a nested array access
        const nestedArrayMatch = schemaKey.match(/(.*?)\.\[\*\]\.(.*)/);
        if (nestedArrayMatch) {
            const [, arrayKey, propertyKey] = nestedArrayMatch;
            const arrayValue = JSON.parse(variables[`{{schema:${arrayKey}}}`] || '[]');
            if (Array.isArray(arrayValue)) {
                schemaValue = JSON.stringify(arrayValue.map(item => item[propertyKey]).filter(Boolean));
            }
        }
        else {
            schemaValue = variables[`{{schema:${schemaKey}}}`] || '';
        }
        const filterNames = filtersString.split('|').filter(Boolean);
        const result = applyFilters(schemaValue, filterNames);
        return result;
    });
}
export function replaceVariables(tabId, text, variables) {
    return __awaiter(this, void 0, void 0, function* () {
        const regex = /{{(?:schema:)?(?:selector:)?(.*?)}}/g;
        const matches = text.match(regex);
        if (matches) {
            for (const match of matches) {
                let replacement;
                if (match.startsWith('{{selector:')) {
                    replacement = yield processSelector(tabId, match);
                }
                else if (match.startsWith('{{schema:')) {
                    replacement = yield processSchema(match, variables);
                }
                else {
                    replacement = yield processVariable(match, variables);
                }
                text = text.replace(match, replacement);
            }
        }
        return text;
    });
}
export function extractPageContent(tabId) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve) => {
            chrome.tabs.sendMessage(tabId, { action: "getPageContent" }, function (response) {
                if (response && response.content) {
                    resolve({
                        content: response.content,
                        selectedHtml: response.selectedHtml,
                        extractedContent: response.extractedContent,
                        schemaOrgData: response.schemaOrgData
                    });
                }
                else {
                    resolve(null);
                }
            });
        });
    });
}
export function getMetaContent(doc, attr, value) {
    var _a, _b;
    const selector = `meta[${attr}]`;
    const element = Array.from(doc.querySelectorAll(selector))
        .find(el => { var _a; return ((_a = el.getAttribute(attr)) === null || _a === void 0 ? void 0 : _a.toLowerCase()) === value.toLowerCase(); });
    return element ? (_b = (_a = element.getAttribute("content")) === null || _a === void 0 ? void 0 : _a.trim()) !== null && _b !== void 0 ? _b : "" : "";
}
export function extractContentBySelector(tabId, selector) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve) => {
            const attributeMatch = selector.match(/:([a-zA-Z-]+)$/);
            let baseSelector = selector;
            let attribute;
            if (attributeMatch) {
                attribute = attributeMatch[1];
                baseSelector = selector.slice(0, -attribute.length - 1);
            }
            chrome.tabs.sendMessage(tabId, { action: "extractContent", selector: baseSelector, attribute: attribute }, function (response) {
                let content = response ? response.content : '';
                // Ensure content is always a string
                if (Array.isArray(content)) {
                    content = JSON.stringify(content);
                }
                resolve({
                    content: content,
                    schemaOrgData: response ? response.schemaOrgData : null
                });
            });
        });
    });
}
export function initializePageContent(content, selectedHtml, extractedContent, currentUrl, schemaOrgData) {
    return __awaiter(this, void 0, void 0, function* () {
        var _a, _b;
        const readabilityArticle = extractReadabilityContent(content);
        if (!readabilityArticle) {
            console.error('Failed to parse content with Readability');
            return null;
        }
        const parser = new DOMParser();
        const doc = parser.parseFromString(content, 'text/html');
        // Define preset variables with fallbacks
        const title = getMetaContent(doc, "property", "og:title")
            || getMetaContent(doc, "name", "twitter:title")
            || getMetaContent(doc, "name", "title")
            || ((_b = (_a = doc.querySelector('title')) === null || _a === void 0 ? void 0 : _a.textContent) === null || _b === void 0 ? void 0 : _b.trim())
            || '';
        const noteName = sanitizeFileName(title);
        const author = getMetaContent(doc, "name", "author")
            || getMetaContent(doc, "property", "author")
            || getMetaContent(doc, "name", "twitter:creator")
            || getMetaContent(doc, "property", "og:site_name")
            || getMetaContent(doc, "name", "application-name")
            || getMetaContent(doc, "name", "copyright")
            || '';
        const description = getMetaContent(doc, "name", "description")
            || getMetaContent(doc, "property", "description")
            || getMetaContent(doc, "property", "og:description")
            || getMetaContent(doc, "name", "twitter:description")
            || '';
        const domain = new URL(currentUrl).hostname.replace(/^www\./, '');
        const image = getMetaContent(doc, "property", "og:image")
            || getMetaContent(doc, "name", "twitter:image")
            || '';
        const timeElement = doc.querySelector("time");
        const publishedDate = getMetaContent(doc, "property", "article:published_time")
            || (timeElement === null || timeElement === void 0 ? void 0 : timeElement.getAttribute("datetime"));
        const published = publishedDate ? `${convertDate(new Date(publishedDate))}` : "";
        const site = getMetaContent(doc, "property", "og:site_name")
            || getMetaContent(doc, "name", "application-name")
            || getMetaContent(doc, "name", "copyright")
            || '';
        const markdownBody = createMarkdownContent(content, currentUrl, selectedHtml);
        const currentVariables = {
            '{{author}}': author,
            '{{content}}': markdownBody,
            '{{description}}': description,
            '{{domain}}': domain,
            '{{image}}': image,
            '{{published}}': published,
            '{{site}}': site,
            '{{title}}': title,
            '{{noteName}}': noteName,
            '{{date}}': convertDate(new Date()),
            '{{today}}': convertDate(new Date()),
            '{{url}}': currentUrl
        };
        // Add extracted content to variables
        Object.entries(extractedContent).forEach(([key, value]) => {
            currentVariables[`{{${key}}}`] = value;
        });
        // Add all meta tags to variables
        doc.querySelectorAll('meta').forEach(meta => {
            const name = meta.getAttribute('name');
            const property = meta.getAttribute('property');
            const content = meta.getAttribute('content');
            if (name && content) {
                currentVariables[`{{meta:name:${name}}}`] = content;
            }
            if (property && content) {
                currentVariables[`{{meta:property:${property}}}`] = content;
            }
        });
        // Add schema.org data to variables
        if (schemaOrgData) {
            addSchemaOrgDataToVariables(schemaOrgData, currentVariables);
        }
        console.log('Available variables:', currentVariables);
        return {
            noteName,
            currentVariables
        };
    });
}
function convertDate(date) {
    return dayjs(date).format('YYYY-MM-DD');
}
function addSchemaOrgDataToVariables(schemaData, variables, prefix = '') {
    if (Array.isArray(schemaData)) {
        // Add the entire array as a JSON string
        const variableKey = `{{schema:${prefix.slice(0, -1)}}}`;
        variables[variableKey] = JSON.stringify(schemaData);
        // If there's only one item, add it without an index
        if (schemaData.length === 1) {
            addSchemaOrgDataToVariables(schemaData[0], variables, prefix);
        }
        else {
            // If there's more than one item, add them with indices
            schemaData.forEach((item, index) => {
                addSchemaOrgDataToVariables(item, variables, `${prefix}[${index}].`);
            });
        }
    }
    else if (typeof schemaData === 'object' && schemaData !== null) {
        Object.entries(schemaData).forEach(([key, value]) => {
            if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
                const variableKey = `{{schema:${prefix}${key}}}`;
                variables[variableKey] = String(value);
            }
            else if (Array.isArray(value)) {
                addSchemaOrgDataToVariables(value, variables, `${prefix}${key}.`);
            }
            else if (typeof value === 'object' && value !== null) {
                addSchemaOrgDataToVariables(value, variables, `${prefix}${key}.`);
            }
        });
    }
}
//# sourceMappingURL=content-extractor.js.map