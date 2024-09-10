import { getTemplates, saveTemplateSettings, updateTemplateList, getEditingTemplateIndex } from '../managers/template-manager';
import { saveGeneralSettings, updateVaultList, generalSettings } from '../managers/general-settings';
let draggedElement = null;
export function initializeDragAndDrop() {
    const draggableLists = [
        document.getElementById('template-list'),
        document.getElementById('template-properties'),
        document.getElementById('vault-list')
    ];
    draggableLists.forEach(list => {
        if (list) {
            list.addEventListener('dragstart', handleDragStart);
            list.addEventListener('dragover', handleDragOver);
            list.addEventListener('drop', handleDrop);
            list.addEventListener('dragend', handleDragEnd);
        }
    });
}
export function handleDragStart(e) {
    e.stopPropagation(); // Prevent bubbling to the body
    draggedElement = e.target.closest('[draggable]');
    if (draggedElement && e.dataTransfer) {
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', draggedElement.dataset.id || draggedElement.dataset.index || '');
        setTimeout(() => {
            if (draggedElement)
                draggedElement.classList.add('dragging');
        }, 0);
    }
}
export function handleDragOver(e) {
    var _a, _b;
    e.stopPropagation(); // Prevent bubbling to the body
    e.preventDefault();
    if (e.dataTransfer)
        e.dataTransfer.dropEffect = 'move';
    const closestDraggable = e.target.closest('[draggable]');
    if (closestDraggable && closestDraggable !== draggedElement && draggedElement) {
        const rect = closestDraggable.getBoundingClientRect();
        const midY = rect.top + rect.height / 2;
        if (e.clientY < midY) {
            (_a = closestDraggable.parentNode) === null || _a === void 0 ? void 0 : _a.insertBefore(draggedElement, closestDraggable);
        }
        else {
            (_b = closestDraggable.parentNode) === null || _b === void 0 ? void 0 : _b.insertBefore(draggedElement, closestDraggable.nextSibling);
        }
    }
}
export function handleDrop(e) {
    e.stopPropagation(); // Prevent bubbling to the body
    e.preventDefault();
    if (!e.dataTransfer)
        return;
    const draggedItemId = e.dataTransfer.getData('text/plain');
    const list = e.target.closest('ul, #template-properties');
    if (list && draggedElement) {
        const items = Array.from(list.children);
        const newIndex = items.indexOf(draggedElement);
        if (list.id === 'template-list') {
            handleTemplateReorder(draggedItemId, newIndex);
        }
        else if (list.id === 'template-properties') {
            handlePropertyReorder(draggedItemId, newIndex);
        }
        else if (list.id === 'vault-list') {
            handleVaultReorder(newIndex);
        }
        draggedElement.classList.remove('dragging');
    }
    draggedElement = null;
}
export function handleDragEnd() {
    if (draggedElement) {
        draggedElement.classList.remove('dragging');
    }
    draggedElement = null;
}
function handleTemplateReorder(draggedItemId, newIndex) {
    const templates = getTemplates();
    const oldIndex = templates.findIndex(t => t.id === draggedItemId);
    if (oldIndex !== -1 && oldIndex !== newIndex) {
        const [movedTemplate] = templates.splice(oldIndex, 1);
        templates.splice(newIndex, 0, movedTemplate);
        saveTemplateSettings().then(() => {
            updateTemplateList();
        }).catch(error => {
            console.error('Failed to save template settings:', error);
        });
    }
}
function handlePropertyReorder(draggedItemId, newIndex) {
    const editingTemplateIndex = getEditingTemplateIndex();
    if (editingTemplateIndex === -1) {
        console.error('No template is currently being edited');
        return;
    }
    const currentTemplates = getTemplates();
    const template = currentTemplates[editingTemplateIndex];
    if (!template) {
        console.error('Template not found');
        return;
    }
    if (!Array.isArray(template.properties) || template.properties.length === 0) {
        console.error('Template properties array is empty or not an array');
        return;
    }
    const oldIndex = template.properties.findIndex(p => p.id === draggedItemId);
    if (oldIndex === -1) {
        console.error('Property not found');
        return;
    }
    if (oldIndex !== newIndex) {
        const [movedProperty] = template.properties.splice(oldIndex, 1);
        template.properties.splice(newIndex, 0, movedProperty);
        saveTemplateSettings().then(() => {
            updateTemplateList();
        }).catch(error => {
            console.error('Failed to save template settings:', error);
        });
    }
}
function handleVaultReorder(newIndex) {
    if (!draggedElement)
        return;
    const oldIndex = parseInt(draggedElement.dataset.index || '-1');
    if (oldIndex !== -1 && oldIndex !== newIndex) {
        const [movedVault] = generalSettings.vaults.splice(oldIndex, 1);
        generalSettings.vaults.splice(newIndex, 0, movedVault);
        saveGeneralSettings();
        updateVaultList();
    }
}
export function moveItem(array, fromIndex, toIndex) {
    const newArray = [...array];
    const [movedItem] = newArray.splice(fromIndex, 1);
    newArray.splice(toIndex, 0, movedItem);
    return newArray;
}
//# sourceMappingURL=drag-and-drop.js.map