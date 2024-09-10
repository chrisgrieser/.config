var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
export let generalSettings = {
    showMoreActionsButton: true,
    vaults: []
};
export function setLocalStorage(key, value) {
    return new Promise((resolve) => {
        chrome.storage.local.set({ [key]: value }, () => {
            resolve();
        });
    });
}
export function getLocalStorage(key) {
    return new Promise((resolve) => {
        chrome.storage.local.get(key, (result) => {
            resolve(result[key]);
        });
    });
}
export function loadGeneralSettings() {
    return __awaiter(this, void 0, void 0, function* () {
        var _a, _b;
        const data = yield chrome.storage.sync.get(['general_settings', 'vaults']);
        generalSettings = {
            showMoreActionsButton: (_b = (_a = data.general_settings) === null || _a === void 0 ? void 0 : _a.showMoreActionsButton) !== null && _b !== void 0 ? _b : true,
            vaults: data.vaults || []
        };
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
    });
}
//# sourceMappingURL=storage-utils.js.map