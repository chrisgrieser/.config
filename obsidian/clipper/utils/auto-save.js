var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { saveTemplateSettings, editingTemplateIndex } from '../managers/template-manager';
import { updateTemplateList, updateTemplateFromForm } from '../managers/template-ui';
let isReordering = false;
export function initializeAutoSave() {
    const templateForm = document.getElementById('template-settings-form');
    if (!templateForm) {
        console.error('Template form not found');
        return;
    }
    const debounce = (func, delay) => {
        let debounceTimer = null;
        return function (...args) {
            const context = this;
            if (debounceTimer)
                clearTimeout(debounceTimer);
            debounceTimer = setTimeout(() => func.apply(context, args), delay);
        };
    };
    const autoSave = debounce(() => __awaiter(this, void 0, void 0, function* () {
        if (!isReordering) {
            try {
                const warnings = yield saveTemplateSettings();
                if (warnings.length > 0) {
                    updateTemplateList();
                    console.log('Auto-save completed');
                    showWarnings(warnings);
                }
            }
            catch (error) {
                console.error('Auto-save failed:', error);
            }
        }
    }), 1000); // Increased debounce time to 1 second
    templateForm.addEventListener('input', () => {
        if (editingTemplateIndex !== -1) {
            updateTemplateFromForm();
            autoSave();
        }
    });
    const templateProperties = document.getElementById('template-properties');
    if (templateProperties) {
        templateProperties.addEventListener('click', (event) => {
            const target = event.target;
            if (target.classList.contains('remove-property-btn') || target.closest('.remove-property-btn')) {
                if (editingTemplateIndex !== -1) {
                    updateTemplateFromForm();
                    autoSave();
                }
            }
        });
        templateProperties.addEventListener('change', (event) => {
            const target = event.target;
            if (target.classList.contains('property-type')) {
                if (editingTemplateIndex !== -1) {
                    updateTemplateFromForm();
                    autoSave();
                }
            }
        });
    }
}
function showWarnings(warnings) {
    // Add a toast notification for this
    console.warn(warnings.join('\n'));
}
//# sourceMappingURL=auto-save.js.map