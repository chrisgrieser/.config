import { loadTemplates, createDefaultTemplate, getTemplates, findTemplateById, saveTemplateSettings } from '../managers/template-manager';
import { updateTemplateList, showTemplateEditor, resetUnsavedChanges, initializeAddPropertyButton } from '../managers/template-ui';
import { initializeGeneralSettings } from '../managers/general-settings';
import { initializeDragAndDrop } from '../utils/drag-and-drop';
import { initializeAutoSave } from '../utils/auto-save';
import { exportTemplate, importTemplate, initializeDropZone } from '../utils/import-export';
import { createIcons } from 'lucide';
import { icons } from '../icons/icons';
import { showGeneralSettings } from '../managers/general-settings-ui';
import { updateUrl } from '../utils/routing';
document.addEventListener('DOMContentLoaded', () => {
    const newTemplateBtn = document.getElementById('new-template-btn');
    const exportTemplateBtn = document.getElementById('export-template-btn');
    const importTemplateBtn = document.getElementById('import-template-btn');
    const resetDefaultTemplateBtn = document.getElementById('reset-default-template-btn');
    function initializeSettings() {
        initializeGeneralSettings();
        loadTemplates().then((loadedTemplates) => {
            updateTemplateList(loadedTemplates);
            initializeTemplateListeners();
            handleUrlParameters();
        });
        initializeSidebar();
        initializeAutoSave();
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
        const sidebarItems = document.querySelectorAll('.sidebar li[data-section]');
        const sections = document.querySelectorAll('.settings-section');
        const sidebar = document.querySelector('.sidebar');
        if (sidebar) {
            sidebar.addEventListener('click', (event) => {
                const target = event.target;
                if (target.dataset.section === 'general') {
                    showGeneralSettings();
                }
            });
        }
        sidebarItems.forEach(item => {
            item.addEventListener('click', () => {
                const sectionId = item.dataset.section;
                sidebarItems.forEach(i => i.classList.remove('active'));
                item.classList.add('active');
                document.querySelectorAll('#template-list li').forEach(templateItem => templateItem.classList.remove('active'));
                const templateEditor = document.getElementById('template-editor');
                if (templateEditor) {
                    templateEditor.style.display = 'none';
                }
                sections.forEach(section => {
                    if (section.id === `${sectionId}-section`) {
                        section.style.display = 'block';
                        section.classList.add('active');
                    }
                    else {
                        section.style.display = 'none';
                        section.classList.remove('active');
                    }
                });
            });
        });
    }
    const templateForm = document.getElementById('template-settings-form');
    if (templateForm) {
        initializeAutoSave();
        initializeDragAndDrop();
        initializeDropZone();
        initializeAddPropertyButton();
    }
    initializeSettings();
});
//# sourceMappingURL=settings.js.map