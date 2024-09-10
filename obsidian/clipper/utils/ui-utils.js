import { setEditingTemplateIndex } from '../managers/template-manager';
export function initializeSidebar() {
    const sidebarItems = document.querySelectorAll('.sidebar li[data-section]');
    const sections = document.querySelectorAll('.settings-section');
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
            setEditingTemplateIndex(-1);
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
export function initializeToggles() {
    const checkboxContainers = document.querySelectorAll('.checkbox-container');
    checkboxContainers.forEach(container => {
        const checkbox = container.querySelector('input[type="checkbox"]');
        if (checkbox) {
            // Update toggle state based on checkbox
            updateToggleState(container, checkbox);
            checkbox.addEventListener('change', () => {
                updateToggleState(container, checkbox);
            });
            container.addEventListener('click', (event) => {
                event.preventDefault();
                checkbox.checked = !checkbox.checked;
                checkbox.dispatchEvent(new Event('change'));
            });
        }
    });
}
function updateToggleState(container, checkbox) {
    if (checkbox.checked) {
        container.classList.add('is-enabled');
    }
    else {
        container.classList.remove('is-enabled');
    }
}
//# sourceMappingURL=ui-utils.js.map