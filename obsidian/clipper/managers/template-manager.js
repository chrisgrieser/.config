var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { compressToUTF16, decompressFromUTF16 } from 'lz-string';
export let templates = [];
export let editingTemplateIndex = -1;
const STORAGE_KEY_PREFIX = 'template_';
const TEMPLATE_LIST_KEY = 'template_list';
const CHUNK_SIZE = 8000;
const SIZE_WARNING_THRESHOLD = 6000;
export function setEditingTemplateIndex(index) {
    editingTemplateIndex = index;
}
export function loadTemplates() {
    return new Promise((resolve) => {
        chrome.storage.sync.get(TEMPLATE_LIST_KEY, (data) => __awaiter(this, void 0, void 0, function* () {
            const templateIds = data[TEMPLATE_LIST_KEY] || [];
            const loadedTemplates = [];
            for (const id of templateIds) {
                const template = yield loadTemplate(id);
                if (template) {
                    loadedTemplates.push(template);
                }
            }
            if (loadedTemplates.length === 0) {
                const defaultTemplate = createDefaultTemplate();
                loadedTemplates.push(defaultTemplate);
                yield saveTemplateSettings();
            }
            templates = loadedTemplates;
            resolve(templates);
        }));
    });
}
function loadTemplate(id) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve) => {
            chrome.storage.sync.get(STORAGE_KEY_PREFIX + id, (data) => {
                const compressedChunks = data[STORAGE_KEY_PREFIX + id];
                if (compressedChunks) {
                    const decompressedData = decompressFromUTF16(compressedChunks.join(''));
                    resolve(JSON.parse(decompressedData));
                }
                else {
                    resolve(null);
                }
            });
        });
    });
}
export function saveTemplateSettings() {
    return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
        try {
            const templateIds = templates.map(t => t.id);
            const warnings = [];
            const templateChunks = {};
            for (const template of templates) {
                const [chunks, warning] = yield prepareTemplateForSave(template);
                templateChunks[STORAGE_KEY_PREFIX + template.id] = chunks;
                if (warning) {
                    warnings.push(warning);
                }
            }
            // Save template list and individual templates
            chrome.storage.sync.set(Object.assign(Object.assign({}, templateChunks), { [TEMPLATE_LIST_KEY]: templateIds }), () => {
                if (chrome.runtime.lastError) {
                    console.error('Error saving templates:', chrome.runtime.lastError);
                    reject(chrome.runtime.lastError);
                }
                else {
                    console.log('Template settings saved');
                    resolve(warnings);
                }
            });
        }
        catch (error) {
            console.error('Error preparing templates for save:', error);
            reject(error);
        }
    }));
}
function prepareTemplateForSave(template) {
    return __awaiter(this, void 0, void 0, function* () {
        const compressedData = compressToUTF16(JSON.stringify(template));
        const chunks = [];
        for (let i = 0; i < compressedData.length; i += CHUNK_SIZE) {
            chunks.push(compressedData.slice(i, i + CHUNK_SIZE));
        }
        // Check if the template size is approaching the limit
        if (compressedData.length > SIZE_WARNING_THRESHOLD) {
            return [chunks, `Warning: Template "${template.name}" is ${(compressedData.length / 1024).toFixed(2)}KB, which is approaching the storage limit.`];
        }
        return [chunks, null];
    });
}
export function createDefaultTemplate() {
    return {
        id: Date.now().toString() + Math.random().toString(36).slice(2, 11),
        name: 'Default',
        behavior: 'create',
        noteNameFormat: '{{title}}',
        path: 'Clippings',
        noteContentFormat: '{{content}}',
        properties: [
            { id: Date.now().toString() + Math.random().toString(36).slice(2, 11), name: 'title', value: '{{title}}', type: 'text' },
            { id: Date.now().toString() + Math.random().toString(36).slice(2, 11), name: 'source', value: '{{url}}', type: 'text' },
            { id: Date.now().toString() + Math.random().toString(36).slice(2, 11), name: 'author', value: '{{author|wikilink}}', type: 'text' },
            { id: Date.now().toString() + Math.random().toString(36).slice(2, 11), name: 'published', value: '{{published}}', type: 'date' },
            { id: Date.now().toString() + Math.random().toString(36).slice(2, 11), name: 'created', value: '{{date}}', type: 'date' },
            { id: Date.now().toString() + Math.random().toString(36).slice(2, 11), name: 'description', value: '{{description}}', type: 'text' },
            { id: Date.now().toString() + Math.random().toString(36).slice(2, 11), name: 'tags', value: 'clippings', type: 'multitext' }
        ],
        triggers: []
    };
}
export function getEditingTemplateIndex() {
    return editingTemplateIndex;
}
export function getTemplates() {
    return templates;
}
export function findTemplateById(id) {
    return templates.find(template => template.id === id);
}
//# sourceMappingURL=template-manager.js.map