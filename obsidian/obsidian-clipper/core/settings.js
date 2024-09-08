import { loadTemplates, updateTemplateList, showTemplateEditor, saveTemplateSettings, createDefaultTemplate, getTemplates } from '../managers/template-manager';
import { loadGeneralSettings, addVault } from '../managers/vault-manager';
import { initializeSidebar } from '../utils/ui-utils';
import { initializeDragAndDrop } from '../utils/drag-and-drop';
import { initializeAutoSave } from '../utils/auto-save';
import { exportTemplate, importTemplate } from '../utils/import-export';
import { createIcons } from 'lucide';
import { icons } from '../icons/icons';
import { resetUnsavedChanges } from '../managers/template-manager';
import { initializeDropZone } from '../utils/import-export';
document.addEventListener('DOMContentLoaded', () => {
    const vaultInput = document.getElementById('vault-input');
    const newTemplateBtn = document.getElementById('new-template-btn');
    const exportTemplateBtn = document.getElementById('export-template-btn');
    const importTemplateBtn = document.getElementById('import-template-btn');
    const resetDefaultTemplateBtn = document.getElementById('reset-default-template-btn');
    function initializeSettings() {
        loadGeneralSettings();
        loadTemplates().then(() => {
            initializeTemplateListeners();
        });
        initializeSidebar();
        initializeAutoSave();
        initializeDragAndDrop();
        initializeDropZone();
        exportTemplateBtn.addEventListener('click', exportTemplate);
        importTemplateBtn.addEventListener('click', importTemplate);
        resetDefaultTemplateBtn.addEventListener('click', resetDefaultTemplate);
        createIcons({ icons });
    }
    function initializeTemplateListeners() {
        const templateList = document.getElementById('template-list');
        if (templateList) {
            templateList.addEventListener('click', (event) => {
                const target = event.target;
                const listItem = target.closest('li');
                if (listItem && listItem.dataset.id) {
                    const currentTemplates = getTemplates();
                    const selectedTemplate = currentTemplates.find((t) => t.id === listItem.dataset.id);
                    if (selectedTemplate) {
                        resetUnsavedChanges();
                        showTemplateEditor(selectedTemplate);
                    }
                }
            });
        }
        else {
            console.error('Template list not found');
        }
        if (newTemplateBtn) {
            newTemplateBtn.addEventListener('click', () => {
                showTemplateEditor(null);
            });
        }
    }
    if (vaultInput) {
        vaultInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                const newVault = vaultInput.value.trim();
                if (newVault) {
                    addVault(newVault);
                    vaultInput.value = '';
                }
            }
        });
    }
    else {
        console.error('Vault input not found');
    }
    initializeSettings();
});
function resetDefaultTemplate() {
    const defaultTemplate = createDefaultTemplate();
    const currentTemplates = getTemplates();
    const defaultIndex = currentTemplates.findIndex((t) => t.name === 'Default');
    if (defaultIndex !== -1) {
        currentTemplates[defaultIndex] = defaultTemplate;
    }
    else {
        currentTemplates.unshift(defaultTemplate);
    }
    saveTemplateSettings().then(() => {
        updateTemplateList();
        showTemplateEditor(defaultTemplate);
    }).catch(error => {
        console.error('Failed to reset default template:', error);
        alert('Failed to reset default template. Please try again.');
    });
}
//# sourceMappingURL=settings.js.map