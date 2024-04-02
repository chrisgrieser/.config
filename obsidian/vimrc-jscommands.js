// @ts-nocheck
// DOCS https://github.com/esm7/obsidian-vimrc-support/blob/master/JsSnippets.md
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: <explanation>
function origamiH() {
	// biome-ignore lint/correctness/noUndeclaredVariables: <explanation>
	const editor = view.editor;
	const col = editor.getCursor().ch;
	// DOCS https://docs.obsidian.md/Reference/TypeScript+API/EditorCommandName
	const action = col > 0 ? "goLeft" : "toggleFold";
	editor.exec(action);
}

// biome-ignore lint/correctness/noUnusedVariables: <explanation>
function origamiL() {
	// biome-ignore lint/correctness/noUndeclaredVariables: <explanation>
	const editor = view.editor;

	const currentLn = editor.getCursor().line;
	const folds = editor.getFoldOffsets();
	const foldedLines = [...folds].map((offset) => {
		return editor.offsetToPos(offset).line;
	});
	const isOnFoldedLine = foldedLines.includes(currentLn);

	const action = isOnFoldedLine ? "toggleFold" : "goRight";
	editor.exec(action);
}
