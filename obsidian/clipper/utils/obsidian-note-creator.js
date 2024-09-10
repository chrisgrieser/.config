var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import dayjs from 'dayjs';
export function generateFrontmatter(properties) {
    return __awaiter(this, void 0, void 0, function* () {
        let frontmatter = '---\n';
        for (const property of properties) {
            frontmatter += `${property.name}:`;
            switch (property.type) {
                case 'multitext':
                    let items;
                    if (property.value.trim().startsWith('["') && property.value.trim().endsWith('"]')) {
                        try {
                            items = JSON.parse(property.value);
                        }
                        catch (e) {
                            // If parsing fails, fall back to splitting by comma
                            items = property.value.split(',').map(item => item.trim());
                        }
                    }
                    else {
                        // Split by comma, but keep wikilinks intact
                        items = property.value.split(/,(?![^\[]*\]\])/).map(item => item.trim());
                    }
                    items = items.filter(item => item !== '');
                    if (items.length > 0) {
                        frontmatter += '\n';
                        items.forEach(item => {
                            frontmatter += `  - "${item}"\n`;
                        });
                    }
                    else {
                        frontmatter += '\n';
                    }
                    break;
                case 'number':
                    const numericValue = property.value.replace(/[^\d.-]/g, '');
                    frontmatter += numericValue ? ` ${parseFloat(numericValue)}\n` : '\n';
                    break;
                case 'checkbox':
                    frontmatter += ` ${property.value.toLowerCase() === 'true' || property.value === '1'}\n`;
                    break;
                case 'date':
                case 'datetime':
                    if (property.value.trim() !== '') {
                        frontmatter += ` "${property.value}"\n`;
                    }
                    else {
                        frontmatter += '\n';
                    }
                    break;
                default: // Text
                    frontmatter += property.value.trim() !== '' ? ` "${property.value}"\n` : '\n';
            }
        }
        frontmatter += '---\n';
        return frontmatter;
    });
}
export function saveToObsidian(fileContent, noteName, path, vault, behavior, specificNoteName, dailyNoteFormat) {
    let obsidianUrl;
    let content = fileContent;
    // Ensure path ends with a slash
    if (path && !path.endsWith('/')) {
        path += '/';
    }
    if (behavior === 'append-specific' || behavior === 'append-daily') {
        let appendFileName;
        if (behavior === 'append-specific') {
            appendFileName = specificNoteName;
        }
        else {
            appendFileName = dayjs().format(dailyNoteFormat);
        }
        obsidianUrl = `obsidian://new?file=${encodeURIComponent(path + appendFileName)}&append=true`;
        // Add newlines at the beginning to separate from existing content
        content = '\n\n' + content;
    }
    else {
        obsidianUrl = `obsidian://new?file=${encodeURIComponent(path + noteName)}`;
    }
    obsidianUrl += `&content=${encodeURIComponent(content)}`;
    const vaultParam = vault ? `&vault=${encodeURIComponent(vault)}` : '';
    obsidianUrl += vaultParam;
    chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
        const currentTab = tabs[0];
        if (currentTab && currentTab.id) {
            chrome.tabs.update(currentTab.id, { url: obsidianUrl }, function (tab) {
                chrome.notifications.create({
                    type: 'basic',
                    iconUrl: 'icon.png',
                    title: 'Obsidian Clipper',
                    message: 'If prompted, select "Always allow" to open Obsidian automatically in the future.'
                });
            });
        }
    });
}
export function sanitizeFileName(fileName) {
    const isWindows = navigator.platform.indexOf('Win') > -1;
    if (isWindows) {
        fileName = fileName.replace(':', '').replace(/[/\\?%*|"<>]/g, '-');
    }
    else {
        fileName = fileName.replace(':', '').replace(/[/\\]/g, '-');
    }
    return fileName;
}
//# sourceMappingURL=obsidian-note-creator.js.map