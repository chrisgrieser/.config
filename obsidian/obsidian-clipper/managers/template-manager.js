var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { handleDragStart, handleDragOver, handleDrop, handleDragEnd } from '../utils/drag-and-drop';
import { initializeIcons, getPropertyTypeIcon } from '../icons/icons';
import { escapeValue, unescapeValue } from '../utils/string-utils';
import { compressToUTF16, decompressFromUTF16 } from 'lz-string';
import { debounce } from '../utils/debounce';
export let templates = [];
export let editingTemplateIndex = -1;
const STORAGE_KEY_PREFIX = 'template_';
const TEMPLATE_LIST_KEY = 'template_list';
const CHUNK_SIZE = 8000; // slightly less than 8KB to account for overhead
const SIZE_WARNING_THRESHOLD = 6000;
let saveTimeout = null;
let hasUnsavedChanges = false;
export function setEditingTemplateIndex(index) {
    editingTemplateIndex = index;
}
export function loadTemplates() {
    return new Promise((resolve) => {
        chrome.storage.sync.get(TEMPLATE_LIST_KEY, (data) => __awaiter(this, void 0, void 0, function* () {
            const templateIds = data[TEMPLATE_LIST_KEY] || [];
            templates = [];
            for (const id of templateIds) {
                const template = yield loadTemplate(id);
                if (template) {
                    templates.push(template);
                }
            }
            if (templates.length === 0) {
                templates.push(createDefaultTemplate());
            }
            updateTemplateList();
            if (templates.length > 0) {
                showTemplateEditor(templates[0]);
            }
            resolve();
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
export function updateTemplateList() {
    const templateList = document.getElementById('template-list');
    if (!templateList)
        return;
    templateList.innerHTML = '';
    templates.forEach((template, index) => {
        if (template && template.name && template.id) {
            const li = document.createElement('li');
            li.innerHTML = `
				<div class="drag-handle">
					<i data-lucide="grip-vertical"></i>
				</div>
				<span class="template-name">${template.name}</span>
				<button type="button" class="delete-template-btn clickable-icon" aria-label="Delete template">
					<i data-lucide="trash-2"></i>
				</button>
			`;
            li.dataset.id = template.id;
            li.dataset.index = index.toString();
            li.draggable = true;
            li.addEventListener('click', (e) => {
                const target = e.target;
                if (!target.closest('.delete-template-btn')) {
                    showTemplateEditor(template);
                }
            });
            const deleteBtn = li.querySelector('.delete-template-btn');
            if (deleteBtn) {
                deleteBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    deleteTemplate(template.id);
                });
            }
            if (index === editingTemplateIndex) {
                li.classList.add('active');
            }
            templateList.appendChild(li);
        }
        else {
            console.error('Invalid template at index', index, ':', template);
        }
    });
    initializeIcons(templateList);
}
export function showTemplateEditor(template) {
    let editingTemplate;
    if (!template) {
        editingTemplate = {
            id: Date.now().toString() + Math.random().toString(36).slice(2, 11),
            name: 'New template',
            behavior: 'create',
            noteNameFormat: '{{title}}',
            path: 'Clippings',
            noteContentFormat: '{{content}}',
            properties: [],
            urlPatterns: []
        };
        templates.push(editingTemplate);
        editingTemplateIndex = templates.length - 1;
        saveTemplateSettings().then(() => {
            updateTemplateList();
        }).catch(error => {
            console.error('Failed to save new template:', error);
        });
    }
    else {
        editingTemplate = template;
        editingTemplateIndex = templates.findIndex(t => t.id === editingTemplate.id);
    }
    // Ensure properties is always an array
    if (!editingTemplate.properties) {
        editingTemplate.properties = [];
    }
    const templateEditorTitle = document.getElementById('template-editor-title');
    const templateName = document.getElementById('template-name');
    const templateProperties = document.getElementById('template-properties');
    if (templateEditorTitle)
        templateEditorTitle.textContent = 'Edit template';
    if (templateName)
        templateName.value = editingTemplate.name;
    if (templateProperties)
        templateProperties.innerHTML = '';
    const pathInput = document.getElementById('template-path-name');
    if (pathInput)
        pathInput.value = editingTemplate.path;
    const behaviorSelect = document.getElementById('template-behavior');
    const specificNoteContainer = document.getElementById('specific-note-container');
    const dailyNoteFormatContainer = document.getElementById('daily-note-format-container');
    const noteNameFormatContainer = document.getElementById('note-name-format-container');
    const propertiesContainer = document.getElementById('properties-container');
    const propertiesWarning = document.getElementById('properties-warning');
    if (behaviorSelect)
        behaviorSelect.value = editingTemplate.behavior || 'create';
    const specificNoteName = document.getElementById('specific-note-name');
    if (specificNoteName)
        specificNoteName.value = editingTemplate.specificNoteName || '';
    const dailyNoteFormat = document.getElementById('daily-note-format');
    if (dailyNoteFormat)
        dailyNoteFormat.value = editingTemplate.dailyNoteFormat || 'YYYY-MM-DD';
    const noteNameFormat = document.getElementById('note-name-format');
    if (noteNameFormat)
        noteNameFormat.value = editingTemplate.noteNameFormat || '{{title}}';
    const noteContentFormat = document.getElementById('note-content-format');
    if (noteContentFormat)
        noteContentFormat.value = editingTemplate.noteContentFormat || '';
    updateBehaviorFields();
    if (behaviorSelect) {
        behaviorSelect.addEventListener('change', updateBehaviorFields);
    }
    if (editingTemplate && Array.isArray(editingTemplate.properties)) {
        editingTemplate.properties.forEach(property => addPropertyToEditor(property.name, property.value, property.type, property.id));
    }
    const urlPatternsTextarea = document.getElementById('url-patterns');
    if (urlPatternsTextarea)
        urlPatternsTextarea.value = editingTemplate && editingTemplate.urlPatterns ? editingTemplate.urlPatterns.join('\n') : '';
    const templateEditor = document.getElementById('template-editor');
    if (templateEditor)
        templateEditor.style.display = 'block';
    const templatesSection = document.getElementById('templates-section');
    if (templatesSection)
        templatesSection.style.display = 'block';
    const generalSection = document.getElementById('general-section');
    if (generalSection)
        generalSection.style.display = 'none';
    document.querySelectorAll('.sidebar li[data-section]').forEach(item => item.classList.remove('active'));
    document.querySelectorAll('#template-list li').forEach(item => item.classList.remove('active'));
    if (editingTemplateIndex !== -1) {
        const activeTemplateItem = document.querySelector(`#template-list li[data-id="${templates[editingTemplateIndex].id}"]`);
        if (activeTemplateItem) {
            activeTemplateItem.classList.add('active');
        }
    }
    if (templatesSection)
        templatesSection.classList.add('active');
    if (generalSection)
        generalSection.classList.remove('active');
    updateTemplateList();
    if (!editingTemplate.id) {
        const templateNameField = document.getElementById('template-name');
        if (templateNameField) {
            templateNameField.focus();
            templateNameField.select();
        }
    }
    resetUnsavedChanges();
    if (templateName) {
        templateName.addEventListener('input', debounce(() => {
            if (editingTemplateIndex !== -1 && templates[editingTemplateIndex]) {
                templates[editingTemplateIndex].name = templateName.value;
                updateTemplateList();
                hasUnsavedChanges = true;
            }
        }, 200));
    }
    hasUnsavedChanges = true;
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
export function saveTemplateSettings() {
    return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
        try {
            const templateIds = templates.map(t => t.id);
            const templateData = {
                [TEMPLATE_LIST_KEY]: templateIds
            };
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
                    hasUnsavedChanges = false;
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
        urlPatterns: []
    };
}
export function deleteTemplate(templateId) {
    const index = templates.findIndex(t => t.id === templateId);
    if (index !== -1) {
        if (confirm(`Are you sure you want to delete the template "${templates[index].name}"?`)) {
            templates.splice(index, 1);
            if (editingTemplateIndex === index) {
                if (templates.length > 0) {
                    const newIndex = Math.max(0, index - 1);
                    showTemplateEditor(templates[newIndex]);
                }
                else {
                    clearTemplateEditor();
                }
            }
            else if (editingTemplateIndex > index) {
                editingTemplateIndex--;
            }
            saveTemplateSettings();
            updateTemplateList();
        }
    }
}
function clearTemplateEditor() {
    editingTemplateIndex = -1;
    const templateEditorTitle = document.getElementById('template-editor-title');
    const templateName = document.getElementById('template-name');
    const templateProperties = document.getElementById('template-properties');
    if (templateEditorTitle)
        templateEditorTitle.textContent = 'New template';
    if (templateName)
        templateName.value = '';
    if (templateProperties)
        templateProperties.innerHTML = '';
    const pathInput = document.getElementById('template-path-name');
    if (pathInput)
        pathInput.value = 'Clippings';
    const urlPatternsTextarea = document.getElementById('url-patterns');
    if (urlPatternsTextarea)
        urlPatternsTextarea.value = '';
    const templateEditor = document.getElementById('template-editor');
    if (templateEditor)
        templateEditor.style.display = 'none';
}
export function addPropertyToEditor(name = '', value = '', type = 'text', id = null) {
    const templateProperties = document.getElementById('template-properties');
    if (!templateProperties)
        return;
    const propertyDiv = document.createElement('div');
    propertyDiv.className = 'property-editor';
    propertyDiv.innerHTML = `
		<div class="drag-handle">
			<i data-lucide="grip-vertical"></i>
		</div>
		<div class="property-select">
			<div class="property-selected" data-value="${type}">
				<i data-lucide="${getPropertyTypeIcon(type)}"></i>
			</div>
			<select class="property-type">
				<option value="text">Text</option>
				<option value="multitext">List</option>
				<option value="number">Number</option>
				<option value="checkbox">Checkbox</option>
				<option value="date">Date</option>
				<option value="datetime">Date & time</option>
			</select>
		</div>
		<input type="text" class="property-name" value="${name}" placeholder="Property name">
		<input type="text" class="property-value" value="${escapeHtml(unescapeValue(value))}" placeholder="Property value">
		<button type="button" class="remove-property-btn clickable-icon" aria-label="Remove property">
			<i data-lucide="trash-2"></i>
		</button>
	`;
    propertyDiv.dataset.id = id || Date.now().toString() + Math.random().toString(36).slice(2, 11);
    templateProperties.appendChild(propertyDiv);
    propertyDiv.addEventListener('mousedown', (event) => {
        const target = event.target;
        if (!target.closest('input, select, button')) {
            propertyDiv.setAttribute('draggable', 'true');
            templateProperties.querySelectorAll('.property-editor').forEach((el) => {
                if (el !== propertyDiv) {
                    el.setAttribute('draggable', 'true');
                }
            });
        }
    });
    const resetDraggable = () => {
        propertyDiv.removeAttribute('draggable');
        templateProperties.querySelectorAll('.property-editor').forEach((el) => {
            el.removeAttribute('draggable');
        });
    };
    propertyDiv.addEventListener('dragend', resetDraggable);
    propertyDiv.addEventListener('mouseup', resetDraggable);
    const propertySelect = propertyDiv.querySelector('.property-select');
    if (!propertySelect)
        return;
    const propertySelected = propertySelect.querySelector('.property-selected');
    const hiddenSelect = propertySelect.querySelector('select');
    if (hiddenSelect) {
        hiddenSelect.value = type;
        hiddenSelect.addEventListener('change', function () {
            if (propertySelected)
                updateSelectedOption(this.value, propertySelected);
        });
    }
    const removePropertyBtn = propertyDiv.querySelector('.remove-property-btn');
    if (removePropertyBtn) {
        removePropertyBtn.addEventListener('click', () => {
            templateProperties.removeChild(propertyDiv);
        });
    }
    propertyDiv.addEventListener('dragstart', handleDragStart);
    propertyDiv.addEventListener('dragover', handleDragOver);
    propertyDiv.addEventListener('drop', handleDrop);
    propertyDiv.addEventListener('dragend', handleDragEnd);
    if (propertySelected)
        updateSelectedOption(type, propertySelected);
    initializeIcons(propertyDiv);
}
function updateSelectedOption(value, propertySelected) {
    const iconName = getPropertyTypeIcon(value);
    propertySelected.innerHTML = `<i data-lucide="${iconName}"></i>`;
    propertySelected.setAttribute('data-value', value);
    initializeIcons(propertySelected);
}
export function updateTemplateFromForm() {
    if (editingTemplateIndex === -1)
        return;
    const template = templates[editingTemplateIndex];
    if (!template) {
        console.error('Template not found');
        return;
    }
    const behaviorSelect = document.getElementById('template-behavior');
    if (behaviorSelect)
        template.behavior = behaviorSelect.value;
    const pathInput = document.getElementById('template-path-name');
    if (pathInput)
        template.path = pathInput.value;
    const noteNameFormat = document.getElementById('note-name-format');
    if (noteNameFormat)
        template.noteNameFormat = noteNameFormat.value;
    const specificNoteName = document.getElementById('specific-note-name');
    if (specificNoteName)
        template.specificNoteName = specificNoteName.value;
    const dailyNoteFormat = document.getElementById('daily-note-format');
    if (dailyNoteFormat)
        template.dailyNoteFormat = dailyNoteFormat.value;
    const noteContentFormat = document.getElementById('note-content-format');
    if (noteContentFormat)
        template.noteContentFormat = noteContentFormat.value;
    const propertyElements = document.querySelectorAll('#template-properties .property-editor');
    template.properties = Array.from(propertyElements).map(prop => {
        const nameInput = prop.querySelector('.property-name');
        const valueInput = prop.querySelector('.property-value');
        const typeSelect = prop.querySelector('.property-select .property-selected');
        return {
            id: prop.dataset.id || Date.now().toString() + Math.random().toString(36).slice(2, 11),
            name: nameInput.value,
            value: escapeValue(valueInput.value),
            type: typeSelect.getAttribute('data-value') || 'text'
        };
    });
    const urlPatternsTextarea = document.getElementById('url-patterns');
    if (urlPatternsTextarea)
        template.urlPatterns = urlPatternsTextarea.value.split('\n').filter(Boolean);
    hasUnsavedChanges = true;
}
export function resetUnsavedChanges() {
    hasUnsavedChanges = false;
}
export function getEditingTemplateIndex() {
    return editingTemplateIndex;
}
export function getTemplates() {
    return templates;
}
function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
function updateBehaviorFields() {
    const behaviorSelect = document.getElementById('template-behavior');
    const specificNoteContainer = document.getElementById('specific-note-container');
    const dailyNoteFormatContainer = document.getElementById('daily-note-format-container');
    const noteNameFormatContainer = document.getElementById('note-name-format-container');
    const propertiesContainer = document.getElementById('properties-container');
    const propertiesWarning = document.getElementById('properties-warning');
    if (behaviorSelect) {
        const selectedBehavior = behaviorSelect.value;
        if (specificNoteContainer)
            specificNoteContainer.style.display = selectedBehavior === 'append-specific' ? 'block' : 'none';
        if (dailyNoteFormatContainer)
            dailyNoteFormatContainer.style.display = selectedBehavior === 'append-daily' ? 'block' : 'none';
        if (noteNameFormatContainer)
            noteNameFormatContainer.style.display = selectedBehavior === 'create' ? 'block' : 'none';
        if (selectedBehavior === 'append-specific' || selectedBehavior === 'append-daily') {
            if (propertiesContainer)
                propertiesContainer.style.display = 'none';
            if (propertiesWarning)
                propertiesWarning.style.display = 'block';
        }
        else {
            if (propertiesContainer)
                propertiesContainer.style.display = 'block';
            if (propertiesWarning)
                propertiesWarning.style.display = 'none';
        }
    }
}
//# sourceMappingURL=template-manager.js.map