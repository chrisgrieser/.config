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

	if (foldedLines.includes(currentLn)) editor.exec("toggleFold");
	editor.exec("goRight");
}

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function toggleLineNumbers() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const vault = view.app.vault;
	vault.setConfig("showLineNumber", !vault.getConfig("showLineNumber"));
}
