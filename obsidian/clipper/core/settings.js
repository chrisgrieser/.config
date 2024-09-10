import { loadTemplates, updateTemplateList, showTemplateEditor, saveTemplateSettings, createDefaultTemplate, getTemplates, findTemplateById } from '../managers/template-manager';
import { initializeGeneralSettings, addVault } from '../managers/general-settings';
import { initializeDragAndDrop } from '../utils/drag-and-drop';
import { initializeAutoSave } from '../utils/auto-save';
import { exportTemplate, importTemplate } from '../utils/import-export';
import { createIcons } from 'lucide';
import { icons } from '../icons/icons';
import { resetUnsavedChanges } from '../managers/template-manager';
import { initializeDropZone } from '../utils/import-export';
function updateUrl(section, templateId) {
    let url = `${window.location.pathname}?section=${section}`;
    if (templateId) {
        url += `&template=${templateId}`;
    }
    window.history.pushState({}, '', url);
}
document.addEventListener('DOMContentLoaded', () => {
    const vaultInput = document.getElementById('vault-input');
    const newTemplateBtn = document.getElementById('new-template-btn');
    const exportTemplateBtn = document.getElementById('export-template-btn');
    const importTemplateBtn = document.getElementById('import-template-btn');
    const resetDefaultTemplateBtn = document.getElementById('reset-default-template-btn');
    function initializeSettings() {
        initializeGeneralSettings();
        loadTemplates().then(() => {
            initializeTemplateListeners();
            handleUrlParameters();
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
                        updateUrl('templates', selectedTemplate.id);
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
    function handleUrlParameters() {
        const urlParams = new URLSearchParams(window.location.search);
        const section = urlParams.get('section');
        const templateId = urlParams.get('template');
        if (section === 'general') {
            showGeneralSettings();
        }
        else if (templateId) {
            const template = findTemplateById(templateId);
            if (template) {
                showTemplateEditor(template);
            }
            else {
                console.error(`Template with id ${templateId} not found`);
                showGeneralSettings();
            }
        }
        else {
            showGeneralSettings();
        }
    }
    function showGeneralSettings() {
        const generalSection = document.getElementById('general-section');
        const templatesSection = document.getElementById('templates-section');
        if (generalSection) {
            generalSection.style.display = 'block';
            generalSection.classList.add('active');
        }
        if (templatesSection) {
            templatesSection.style.display = 'none';
            templatesSection.classList.remove('active');
        }
        updateUrl('general');
        // Update sidebar active state
        document.querySelectorAll('.sidebar li').forEach(item => item.classList.remove('active'));
        const generalItem = document.querySelector('.sidebar li[data-section="general"]');
        if (generalItem)
            generalItem.classList.add('active');
    }
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
    function initializeSidebar() {
        const sidebar = document.querySelector('.sidebar');
        if (sidebar) {
            sidebar.addEventListener('click', (event) => {
                const target = event.target;
                if (target.dataset.section === 'general') {
                    showGeneralSettings();
                }
            });
        }
    }
    initializeSettings();
});
export { updateUrl };
//# sourceMappingURL=settings.js.map