export function escapeValue(value) {
    return value.replace(/"/g, '\\"').replace(/\n/g, '\\n');
}
export function unescapeValue(value) {
    return value.replace(/\\"/g, '"').replace(/\\n/g, '\n');
}
//# sourceMappingURL=string-utils.js.map