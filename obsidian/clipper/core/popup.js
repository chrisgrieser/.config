var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import dayjs from 'dayjs';
import { generateFrontmatter, saveToObsidian, sanitizeFileName } from '../utils/obsidian-note-creator';
import { extractPageContent, initializePageContent, replaceVariables } from '../utils/content-extractor';
import { initializeIcons, getPropertyTypeIcon } from '../icons/icons';
import { unescapeValue } from '../utils/string-utils';
import { decompressFromUTF16 } from 'lz-string';
import { getLocalStorage, setLocalStorage } from '../utils/storage-utils';
import { findMatchingTemplate, matchPattern } from '../utils/triggers';
import { formatVariables } from '../utils/string-utils';
import { loadGeneralSettings } from '../managers/general-settings';
let currentTemplate = null;
let templates = [];
let currentVariables = {};
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === "triggerQuickClip") {
        handleClip().then(() => {
            sendResponse({ success: true });
        }).catch((error) => {
            console.error('Error in handleClip:', error);
            sendResponse({ success: false, error: error.message });
        });
        return true;
    }
});
function showError(message) {
    const errorMessage = document.querySelector('.error-message');
    const clipper = document.querySelector('.clipper');
    if (errorMessage && clipper) {
        errorMessage.textContent = message;
        errorMessage.style.display = 'block';
        clipper.style.display = 'none';
        // Ensure the settings icon is still visible when showing an error
        const settingsIcon = document.getElementById('open-settings');
        if (settingsIcon) {
            settingsIcon.style.display = 'flex';
        }
    }
}
function handleClip() {
    return __awaiter(this, void 0, void 0, function* () {
        if (!currentTemplate)
            return;
        const vaultDropdown = document.getElementById('vault-select');
        const noteContentField = document.getElementById('note-content-field');
        const noteNameField = document.getElementById('note-name-field');
        const pathField = document.getElementById('path-name-field');
        if (!vaultDropdown || !noteContentField || !noteNameField || !pathField) {
            showError('Some required fields are missing. Please try reloading the extension.');
            return;
        }
        const selectedVault = currentTemplate.vault || vaultDropdown.value;
        const noteContent = noteContentField.value;
        const noteName = noteNameField.value;
        const path = pathField.value;
        const properties = Array.from(document.querySelectorAll('.metadata-property input')).map(input => ({
            name: input.id,
            value: input.value,
            type: input.getAttribute('data-type') || 'text'
        }));
        let fileContent;
        if (currentTemplate.behavior === 'create') {
            const frontmatter = yield generateFrontmatter(properties);
            fileContent = frontmatter + noteContent;
        }
        else {
            fileContent = noteContent;
        }
        try {
            yield saveToObsidian(fileContent, noteName, path, selectedVault, currentTemplate.behavior, currentTemplate.specificNoteName, currentTemplate.dailyNoteFormat);
            setTimeout(() => window.close(), 50);
        }
        catch (error) {
            console.error('Error in handleClip:', error);
            showError('Failed to save to Obsidian. Please try again.');
            throw error; // Re-throw the error so it can be caught by the caller
        }
    });
}
document.addEventListener('DOMContentLoaded', function () {
    return __awaiter(this, void 0, void 0, function* () {
        initializeIcons();
        const vaultContainer = document.getElementById('vault-container');
        const vaultDropdown = document.getElementById('vault-select');
        const templateContainer = document.getElementById('template-container');
        const templateDropdown = document.getElementById('template-select');
        let vaults = [];
        // Load vaults from storage and populate dropdown
        chrome.storage.sync.get(['vaults'], (data) => {
            vaults = data.vaults || [];
            updateVaultDropdown();
        });
        function updateVaultDropdown() {
            vaultDropdown.innerHTML = '';
            vaults.forEach(vault => {
                const option = document.createElement('option');
                option.value = vault;
                option.textContent = vault;
                vaultDropdown.appendChild(option);
            });
            // Only show vault selector if one is defined
            if (vaults.length > 0) {
                vaultContainer.style.display = 'block';
                vaultDropdown.value = vaults[0];
            }
            else {
                vaultContainer.style.display = 'none';
            }
        }
        // Load templates from sync storage and populate dropdown
        chrome.storage.sync.get(['template_list'], (data) => __awaiter(this, void 0, void 0, function* () {
            const templateIds = data.template_list || [];
            const loadedTemplates = yield Promise.all(templateIds.map(id => new Promise(resolve => chrome.storage.sync.get(`template_${id}`, data => {
                const compressedChunks = data[`template_${id}`];
                if (compressedChunks) {
                    const decompressedData = decompressFromUTF16(compressedChunks.join(''));
                    resolve(JSON.parse(decompressedData));
                }
                else {
                    resolve(null);
                }
            }))));
            templates = loadedTemplates.filter((t) => t !== null);
            if (templates.length === 0) {
                console.error('No templates found in storage');
                return;
            }
            populateTemplateDropdown();
            // After templates are loaded, match template based on URL
            chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
                return __awaiter(this, void 0, void 0, function* () {
                    if (!tabs[0].url || tabs[0].url.startsWith('chrome-extension://') || tabs[0].url.startsWith('chrome://') || tabs[0].url.startsWith('about:') || tabs[0].url.startsWith('file://')) {
                        showError('This page cannot be clipped.');
                        return;
                    }
                    const currentUrl = tabs[0].url;
                    if (tabs[0].id) {
                        try {
                            const extractedData = yield extractPageContent(tabs[0].id);
                            if (extractedData) {
                                const initializedContent = yield initializePageContent(extractedData.content, extractedData.selectedHtml, extractedData.extractedContent, currentUrl, extractedData.schemaOrgData);
                                if (initializedContent) {
                                    currentTemplate = findMatchingTemplate(currentUrl, templates, extractedData.schemaOrgData) || templates[0];
                                    if (currentTemplate) {
                                        templateDropdown.value = currentTemplate.name;
                                    }
                                    yield initializeTemplateFields(currentTemplate, initializedContent.currentVariables, initializedContent.noteName, extractedData.schemaOrgData);
                                }
                                else {
                                    showError('Unable to initialize page content.');
                                }
                            }
                            else {
                                showError('Unable to get page content. Try reloading the page.');
                            }
                        }
                        catch (error) {
                            console.error('Error in popup initialization:', error);
                            if (error instanceof Error) {
                                showError(`An error occurred: ${error.message}`);
                            }
                            else {
                                showError('An unexpected error occurred');
                            }
                        }
                    }
                });
            });
            // Only show template selector if there are multiple templates
            if (templates.length > 1) {
                templateContainer.style.display = 'block';
            }
        }));
        function populateTemplateDropdown() {
            templateDropdown.innerHTML = '';
            templates.forEach((template) => {
                const option = document.createElement('option');
                option.value = template.name;
                option.textContent = template.name;
                templateDropdown.appendChild(option);
            });
        }
        function setupMetadataToggle() {
            const metadataHeader = document.querySelector('.metadata-properties-header');
            const metadataProperties = document.querySelector('.metadata-properties');
            if (metadataHeader && metadataProperties) {
                metadataHeader.addEventListener('click', () => {
                    const isCollapsed = metadataProperties.classList.toggle('collapsed');
                    metadataHeader.classList.toggle('collapsed');
                    setLocalStorage('propertiesCollapsed', isCollapsed);
                });
                getLocalStorage('propertiesCollapsed').then((isCollapsed) => {
                    if (isCollapsed) {
                        metadataProperties.classList.add('collapsed');
                        metadataHeader.classList.add('collapsed');
                    }
                    else {
                        metadataProperties.classList.remove('collapsed');
                        metadataHeader.classList.remove('collapsed');
                    }
                });
            }
        }
        // Template selection change
        templateDropdown.addEventListener('change', function () {
            return __awaiter(this, void 0, void 0, function* () {
                currentTemplate = templates.find((t) => t.name === this.value) || null;
                if (currentTemplate) {
                    const tabs = yield chrome.tabs.query({ active: true, currentWindow: true });
                    if (tabs[0].id) {
                        const extractedData = yield extractPageContent(tabs[0].id);
                        if (extractedData) {
                            const initializedContent = yield initializePageContent(extractedData.content, extractedData.selectedHtml, extractedData.extractedContent, tabs[0].url, extractedData.schemaOrgData);
                            if (initializedContent) {
                                yield initializeTemplateFields(currentTemplate, initializedContent.currentVariables, initializedContent.noteName, extractedData.schemaOrgData);
                            }
                            else {
                                showError('Unable to initialize page content.');
                            }
                        }
                        else {
                            showError('Unable to retrieve page content. Try reloading the page.');
                        }
                    }
                }
            });
        });
        const noteNameField = document.getElementById('note-name-field');
        function adjustTextareaHeight(textarea) {
            textarea.style.minHeight = '2rem';
            textarea.style.minHeight = textarea.scrollHeight + 'px';
        }
        function handleNoteNameInput() {
            noteNameField.value = sanitizeFileName(noteNameField.value);
            adjustTextareaHeight(noteNameField);
        }
        noteNameField.addEventListener('input', handleNoteNameInput);
        noteNameField.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
            }
        });
        // Initial height adjustment
        adjustTextareaHeight(noteNameField);
        function initializeTemplateFields(template, variables, noteName, schemaOrgData) {
            return __awaiter(this, void 0, void 0, function* () {
                currentVariables = variables;
                const templateProperties = document.querySelector('.metadata-properties');
                templateProperties.innerHTML = '';
                const tabs = yield chrome.tabs.query({ active: true, currentWindow: true });
                const tabId = tabs[0].id;
                const currentUrl = tabs[0].url || '';
                for (const property of template.properties) {
                    const propertyDiv = document.createElement('div');
                    propertyDiv.className = 'metadata-property';
                    let value = yield replaceVariables(tabId, unescapeValue(property.value), variables);
                    // Apply type-specific parsing
                    switch (property.type) {
                        case 'number':
                            const numericValue = value.replace(/[^\d.-]/g, '');
                            value = numericValue ? parseFloat(numericValue).toString() : value;
                            break;
                        case 'checkbox':
                            value = (value.toLowerCase() === 'true' || value === '1').toString();
                            break;
                        case 'date':
                            value = dayjs(value).isValid() ? dayjs(value).format('YYYY-MM-DD') : value;
                            break;
                        case 'datetime':
                            value = dayjs(value).isValid() ? dayjs(value).format('YYYY-MM-DD HH:mm:ss') : value;
                            break;
                    }
                    propertyDiv.innerHTML = `
				<span class="metadata-property-icon"><i data-lucide="${getPropertyTypeIcon(property.type)}"></i></span>
				<label for="${property.name}">${property.name}</label>
				<input id="${property.name}" type="text" value="${escapeHtml(value)}" data-type="${property.type}" />
			`;
                    templateProperties.appendChild(propertyDiv);
                }
                if (noteNameField) {
                    let formattedNoteName = yield replaceVariables(tabId, template.noteNameFormat, variables);
                    noteNameField.value = sanitizeFileName(formattedNoteName);
                    adjustTextareaHeight(noteNameField);
                }
                const pathField = document.getElementById('path-name-field');
                if (pathField)
                    pathField.value = template.path;
                const noteContentField = document.getElementById('note-content-field');
                if (noteContentField) {
                    if (template.noteContentFormat) {
                        let content = yield replaceVariables(tabId, template.noteContentFormat, variables);
                        noteContentField.value = content;
                    }
                    else {
                        noteContentField.value = '';
                    }
                }
                if (Object.keys(variables).length > 0) {
                    if (template.triggers && template.triggers.length > 0) {
                        const matchingPattern = template.triggers.find(pattern => matchPattern(pattern, currentUrl, schemaOrgData));
                        if (matchingPattern) {
                            console.log(`Matched template trigger: ${matchingPattern}`);
                        }
                    }
                    else {
                        console.log('No template triggers defined for this template');
                    }
                }
                initializeIcons();
                setupMetadataToggle();
                const vaultDropdown = document.getElementById('vault-select');
                if (vaultDropdown) {
                    if (template.vault) {
                        vaultDropdown.value = template.vault;
                    }
                    else {
                        // Try to get the previously selected vault
                        const lastSelectedVault = yield getLocalStorage('lastSelectedVault');
                        if (lastSelectedVault && vaults.includes(lastSelectedVault)) {
                            vaultDropdown.value = lastSelectedVault;
                        }
                        else if (vaults.length > 0) {
                            vaultDropdown.value = vaults[0];
                        }
                    }
                    vaultDropdown.addEventListener('change', () => {
                        setLocalStorage('lastSelectedVault', vaultDropdown.value);
                    });
                }
            });
        }
        const clipButton = document.getElementById('clip-button');
        clipButton.focus();
        document.getElementById('clip-button').addEventListener('click', handleClip);
        document.getElementById('open-settings').addEventListener('click', function () {
            chrome.runtime.openOptionsPage();
        });
        const settings = yield loadGeneralSettings();
        const showMoreActionsButton = document.getElementById('show-variables');
        const variablesPanel = document.createElement('div');
        variablesPanel.className = 'variables-panel';
        document.body.appendChild(variablesPanel);
        if (showMoreActionsButton) {
            showMoreActionsButton.style.display = settings.showMoreActionsButton ? 'flex' : 'none';
            showMoreActionsButton.addEventListener('click', function () {
                if (currentTemplate && Object.keys(currentVariables).length > 0) {
                    const formattedVariables = formatVariables(currentVariables);
                    variablesPanel.innerHTML = `
					<div class="variables-header">
						<h3>Page variables</h3>
						<span class="close-panel clickable-icon" aria-label="Close">
							<i data-lucide="x"></i>
						</span>
					</div>
					<div class="variable-list">${formattedVariables}</div>
				`;
                    variablesPanel.classList.add('show');
                    initializeIcons();
                    // Add click event listeners to variable keys and chevrons
                    const variableItems = variablesPanel.querySelectorAll('.variable-item');
                    variableItems.forEach(item => {
                        const key = item.querySelector('.variable-key');
                        const chevron = item.querySelector('.chevron-icon');
                        const valueElement = item.querySelector('.variable-value');
                        if (valueElement.scrollWidth > valueElement.clientWidth) {
                            item.classList.add('has-overflow');
                        }
                        key.addEventListener('click', function () {
                            const variableName = this.getAttribute('data-variable');
                            if (variableName) {
                                navigator.clipboard.writeText(variableName).then(() => {
                                    const originalText = this.textContent;
                                    this.textContent = 'Copied!';
                                    setTimeout(() => {
                                        this.textContent = originalText;
                                    }, 1000);
                                }).catch(err => {
                                    console.error('Failed to copy text: ', err);
                                });
                            }
                        });
                        chevron.addEventListener('click', function () {
                            item.classList.toggle('is-collapsed');
                            const chevronIcon = this.querySelector('i');
                            if (chevronIcon) {
                                chevronIcon.setAttribute('data-lucide', item.classList.contains('is-collapsed') ? 'chevron-right' : 'chevron-down');
                                initializeIcons();
                            }
                        });
                    });
                    const closePanel = variablesPanel.querySelector('.close-panel');
                    closePanel.addEventListener('click', function () {
                        variablesPanel.classList.remove('show');
                    });
                }
                else {
                    console.log('No variables available to display');
                }
            });
        }
        function escapeHtml(unsafe) {
            return unsafe
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }
    });
});
//# sourceMappingURL=popup.js.map