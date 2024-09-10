export function escapeValue(value) {
    return value.replace(/"/g, '\\"').replace(/\n/g, '\\n');
}
export function unescapeValue(value) {
    return value.replace(/\\"/g, '"').replace(/\\n/g, '\n');
}
export function formatVariables(variables) {
    return Object.entries(variables)
        .map(([key, value]) => `
			<div class="variable-item is-collapsed">
				<span class="variable-key" data-variable="${escapeHtml(key)}">${escapeHtml(key)}</span>
				<span class="variable-value">${escapeHtml(value)}</span>
				<span class="chevron-icon" aria-label="Expand">
					<i data-lucide="chevron-right"></i>
				</span>
			</div>
		 `)
        .join('');
}
function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
//# sourceMappingURL=string-utils.js.map