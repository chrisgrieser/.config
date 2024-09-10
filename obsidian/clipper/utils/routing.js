export function updateUrl(section, templateId) {
    let url = `${window.location.pathname}?section=${section}`;
    if (templateId) {
        url += `&template=${templateId}`;
    }
    window.history.pushState({}, '', url);
}
//# sourceMappingURL=routing.js.map