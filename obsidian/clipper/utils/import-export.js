import { templates, saveTemplateSettings, editingTemplateIndex } from '../managers/template-manager';
import { showTemplateEditor, updateTemplateList } from '../managers/template-ui';
const SCHEMA_VERSION = '0.1.0';
function toKebabCase(str) {
    return str
        .replace(/([a-z])([A-Z])/g, '$1-$2')
        .replace(/[\s_]+/g, '-')
        .toLowerCase();
}
export function exportTemplate() {
    if (editingTemplateIndex === -1) {
        alert('Please select a template to export.');
        return;
    }
    const template = templates[editingTemplateIndex];
    const templateFile = `${toKebabCase(template.name)}-clipper.json`;
    const orderedTemplate = {
        schemaVersion: SCHEMA_VERSION,
        name: template.name,
        behavior: template.behavior,
        noteNameFormat: template.noteNameFormat,
        path: template.path,
        noteContentFormat: template.noteContentFormat,
        properties: template.properties.map(({ name, value, type }) => ({ name, value, type })),
        triggers: template.triggers,
    };
    const jsonContent = JSON.stringify(orderedTemplate, null, 2);
    const blob = new Blob([jsonContent], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = templateFile;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}
export function importTemplate() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    input.onchange = (event) => {
        var _a;
        const file = (_a = event.target.files) === null || _a === void 0 ? void 0 : _a[0];
        if (!file)
            return;
        const reader = new FileReader();
        reader.onload = (e) => {
            var _a, _b;
            try {
                const importedTemplate = JSON.parse((_a = e.target) === null || _a === void 0 ? void 0 : _a.result);
                if (!validateImportedTemplate(importedTemplate)) {
                    throw new Error('Invalid template file');
                }
                importedTemplate.id = Date.now().toString() + Math.random().toString(36).substr(2, 9);
                // Assign new IDs to properties
                importedTemplate.properties = (_b = importedTemplate.properties) === null || _b === void 0 ? void 0 : _b.map(prop => (Object.assign(Object.assign({}, prop), { id: Date.now().toString() + Math.random().toString(36).substr(2, 9) })));
                let newName = importedTemplate.name;
                let counter = 1;
                while (templates.some(t => t.name === newName)) {
                    newName = `${importedTemplate.name} (${counter++})`;
                }
                importedTemplate.name = newName;
                templates.push(importedTemplate);
                saveTemplateSettings();
                updateTemplateList();
                showTemplateEditor(importedTemplate);
            }
            catch (error) {
                console.error('Error parsing imported template:', error);
                alert('Error importing template. Please check the file and try again.');
            }
        };
        reader.readAsText(file);
    };
    input.click();
}
function validateImportedTemplate(template) {
    const requiredFields = ['name', 'behavior', 'path', 'properties', 'noteContentFormat'];
    const validTypes = ['text', 'multitext', 'number', 'checkbox', 'date', 'datetime'];
    return requiredFields.every(field => template.hasOwnProperty(field)) &&
        Array.isArray(template.properties) &&
        template.properties.every(prop => prop.hasOwnProperty('name') &&
            prop.hasOwnProperty('value') &&
            prop.hasOwnProperty('type') &&
            validTypes.includes(prop.type));
}
export function initializeDropZone() {
    const dropZone = document.getElementById('template-drop-zone');
    const body = document.body;
    if (!dropZone) {
        console.error('Drop zone not found');
        return;
    }
    let dragCounter = 0;
    body.addEventListener('dragenter', handleDragEnter, false);
    body.addEventListener('dragleave', handleDragLeave, false);
    body.addEventListener('dragover', handleDragOver, false);
    body.addEventListener('drop', handleDrop, false);
    function handleDragEnter(e) {
        e.preventDefault();
        e.stopPropagation();
        dragCounter++;
        if (isFileDrag(e)) {
            dropZone === null || dropZone === void 0 ? void 0 : dropZone.classList.add('drag-over');
        }
    }
    function handleDragLeave(e) {
        e.preventDefault();
        e.stopPropagation();
        dragCounter--;
        if (dragCounter === 0) {
            dropZone === null || dropZone === void 0 ? void 0 : dropZone.classList.remove('drag-over');
        }
    }
    function handleDragOver(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    function handleDrop(e) {
        var _a;
        e.preventDefault();
        e.stopPropagation();
        dropZone === null || dropZone === void 0 ? void 0 : dropZone.classList.remove('drag-over');
        dragCounter = 0;
        if (isFileDrag(e)) {
            const files = (_a = e.dataTransfer) === null || _a === void 0 ? void 0 : _a.files;
            if (files && files.length) {
                handleFiles(files);
            }
        }
    }
    function isFileDrag(e) {
        var _a;
        if ((_a = e.dataTransfer) === null || _a === void 0 ? void 0 : _a.types) {
            for (let i = 0; i < e.dataTransfer.types.length; i++) {
                if (e.dataTransfer.types[i] === "Files") {
                    return true;
                }
            }
        }
        return false;
    }
}
function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
}
function highlight(e) {
    const dropZone = document.getElementById('template-drop-zone');
    dropZone === null || dropZone === void 0 ? void 0 : dropZone.classList.add('drag-over');
}
function unhighlight(e) {
    const dropZone = document.getElementById('template-drop-zone');
    dropZone === null || dropZone === void 0 ? void 0 : dropZone.classList.remove('drag-over');
}
function handleDrop(e) {
    const dt = e.dataTransfer;
    const files = dt === null || dt === void 0 ? void 0 : dt.files;
    if (files && files.length) {
        handleFiles(files);
    }
}
function handleFiles(files) {
    Array.from(files).forEach(importTemplateFile);
}
function importTemplateFile(file) {
    const reader = new FileReader();
    reader.onload = (e) => {
        var _a, _b;
        try {
            const importedTemplate = JSON.parse((_a = e.target) === null || _a === void 0 ? void 0 : _a.result);
            if (!validateImportedTemplate(importedTemplate)) {
                throw new Error('Invalid template file');
            }
            importedTemplate.id = Date.now().toString() + Math.random().toString(36).substr(2, 9);
            // Assign new IDs to properties
            importedTemplate.properties = (_b = importedTemplate.properties) === null || _b === void 0 ? void 0 : _b.map(prop => (Object.assign(Object.assign({}, prop), { id: Date.now().toString() + Math.random().toString(36).substr(2, 9) })));
            let newName = importedTemplate.name;
            let counter = 1;
            while (templates.some(t => t.name === newName)) {
                newName = `${importedTemplate.name} (${counter++})`;
            }
            importedTemplate.name = newName;
            templates.push(importedTemplate);
            saveTemplateSettings();
            updateTemplateList();
            showTemplateEditor(importedTemplate);
        }
        catch (error) {
            console.error('Error parsing imported template:', error);
            alert('Error importing template. Please check the file and try again.');
        }
    };
    reader.readAsText(file);
}
//# sourceMappingURL=import-export.js.map