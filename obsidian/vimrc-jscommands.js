// @ts-nocheck
// DOCS https://github.com/esm7/obsidian-vimrc-support/blob/master/JsSnippets.md
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function origamiH() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const editor = view.editor;
	const isAtBoL = editor.getCursor().ch === 0;
	const action = isAtBoL ? "toggleFold" : "goLeft";
	editor.exec(action);
}

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function origamiL() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const editor = view.editor;

	const currentLn = editor.getCursor().line;
	const folds = editor.getFoldOffsets();
	const foldedLines = [...folds].map((offset) => editor.offsetToPos(offset).line);

	const action = foldedLines.includes(currentLn) ? "toggleFold" : "goRight";
	editor.exec(action);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function addYamlKey(key, value) {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const editor = view.editor;
	const /** @type {string[]} */ lines = editor.getValue().split("\n");
	const frontmatterEnd = lines.slice(1).findIndex((line) => line === "---");
	if (frontmatterEnd === -1) return;

	const stringifiedValue = typeof value === "string" ? `"${value}"` : value.toString();
	const yamlLine = key + ": " + stringifiedValue;

	const keyLnum = lines
		.slice(0, frontmatterEnd) // only check frontmatter
		.findIndex((line) => line.startsWith(key + ":"));
	if (keyLnum === -1) {
		lines.splice(frontmatterEnd + 1, 0, yamlLine); // insert at frontmatter
	} else {
		lines[keyLnum] = yamlLine; // update existing key
	}
	editor.setValue(lines.join("\n"));
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function toggleLineNumbers() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const vault = view.app.vault;
	vault.setConfig("showLineNumber", !vault.getConfig("showLineNumber"));
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function obsidianUriMdLink() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const app = view.app;
	const activeFile = app.workspace.getActiveFile();
	if (!activeFile) return;
	const filePathEnc = encodeURIComponent(activeFile.path);
	const basename = activeFile.basename;
	const vaultName = app.vault.getName();
	const vaultNameEnc = encodeURIComponent(vaultName);

	const obsidianUri = `obsidian://open?vault=${vaultNameEnc}&file=${filePathEnc}`;
	const mdLink = `[${basename} (${vaultName})](${obsidianUri})`;

	// biome-ignore lint/correctness/noUndeclaredVariables: available via Obsidian API
	new Notice(`Copied Link to "${basename}"`);
	navigator.clipboard.writeText(mdLink);
}
