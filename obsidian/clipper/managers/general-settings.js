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
import { initializeIcons } from '../icons/icons';
import { getCommands } from '../utils/hotkeys';
import { initializeToggles } from '../utils/ui-utils';
export let generalSettings = {
    showMoreActionsButton: true,
    vaults: []
};
export function loadGeneralSettings() {
    return __awaiter(this, void 0, void 0, function* () {
        var _a;
        const data = yield chrome.storage.sync.get(['general_settings', 'vaults']);
        console.log('Loaded general settings:', data.general_settings);
        console.log('Loaded vaults:', data.vaults);
        generalSettings = Object.assign(Object.assign({}, data.general_settings), { vaults: data.vaults || [], showMoreActionsButton: ((_a = data.general_settings) === null || _a === void 0 ? void 0 : _a.showMoreActionsButton) || true });
        return generalSettings;
    });
}
export function saveGeneralSettings(settings) {
    return __awaiter(this, void 0, void 0, function* () {
        generalSettings = Object.assign(Object.assign({}, generalSettings), settings);
        yield chrome.storage.sync.set({
            general_settings: { showMoreActionsButton: generalSettings.showMoreActionsButton },
            vaults: generalSettings.vaults
        });
        console.log('Saved general settings:', generalSettings);
    });
}
export function updateVaultList() {
    const vaultList = document.getElementById('vault-list');
    if (!vaultList)
        return;
    vaultList.innerHTML = '';
    generalSettings.vaults.forEach((vault, index) => {
        const li = document.createElement('li');
        li.innerHTML = `
			<div class="drag-handle">
				<i data-lucide="grip-vertical"></i>
			</div>
			<span>${vault}</span>
			<button type="button" class="remove-vault-btn clickable-icon" aria-label="Remove vault">
				<i data-lucide="trash-2"></i>
			</button>
		`;
        li.dataset.index = index.toString();
        li.draggable = true;
        li.addEventListener('dragstart', handleDragStart);
        li.addEventListener('dragover', handleDragOver);
        li.addEventListener('drop', handleDrop);
        li.addEventListener('dragend', handleDragEnd);
        const removeBtn = li.querySelector('.remove-vault-btn');
        removeBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            removeVault(index);
        });
        vaultList.appendChild(li);
    });
    initializeIcons(vaultList);
}
export function addVault(vault) {
    generalSettings.vaults.push(vault);
    saveGeneralSettings();
    updateVaultList();
}
export function removeVault(index) {
    generalSettings.vaults.splice(index, 1);
    saveGeneralSettings();
    updateVaultList();
}
export function initializeGeneralSettings() {
    loadGeneralSettings().then(() => {
        updateVaultList();
        initializeShowMoreActionsToggle();
        initializeVaultInput();
        initializeKeyboardShortcuts();
        initializeToggles();
    });
}
function initializeShowMoreActionsToggle() {
    const ShowMoreActionsToggle = document.getElementById('show-more-actions-toggle');
    if (ShowMoreActionsToggle) {
        ShowMoreActionsToggle.checked = generalSettings.showMoreActionsButton;
        ShowMoreActionsToggle.addEventListener('change', () => {
            saveGeneralSettings({ showMoreActionsButton: ShowMoreActionsToggle.checked });
        });
    }
}
function initializeVaultInput() {
    const vaultInput = document.getElementById('vault-input');
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
}
function initializeKeyboardShortcuts() {
    const shortcutsList = document.getElementById('keyboard-shortcuts-list');
    if (!shortcutsList)
        return;
    getCommands().then(commands => {
        commands.forEach(command => {
            const shortcutItem = document.createElement('div');
            shortcutItem.className = 'shortcut-item';
            shortcutItem.innerHTML = `
				<span>${command.description}</span>
				<span class="setting-hotkey">${command.shortcut || 'Not set'}</span>
			`;
            shortcutsList.appendChild(shortcutItem);
        });
    });
}
//# sourceMappingURL=general-settings.js.map