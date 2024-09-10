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