/* global app, Notice */
// all hail the @koala
//------------------------------------------------------------------------------

// emulates `:buffer #`
function altBuffer() {
	const recentFiles = app.workspace.lastOpenFiles;
	let altPath;
	let fileExists;
	let i = 0;
	do {
		altPath = recentFiles[i];
		fileExists = app.vault.exists(altPath); // e.g. deleted files
		i++;
	} while (!fileExists && i < recentFiles.length)
	if (!fileExists) {
		new Notice ("There is no recent file that exists.");
		return;
	}
	const altTFile = app.vault.getAbstractFileByPath(altPath);
	app.workspace.activeLeaf.openFile(altTFile);
}

function appendSpace() {
	const editor = app.workspace.activeLeaf.view.editor;
	const pos = editor.getCursor();
	const convPos = editor.posToOffset(pos);
	const cm6 = editor.cm;
	const transaction = cm6.state.update({ changes: { from: convPos + 1, to: convPos + 1, insert: " " } });
	cm6.dispatch(transaction);
}

// VIM SNEAK
function extractRegexp(text, chars, currentCursor, forward) {
	const textFromCursor = forward ? text.substring(currentCursor + 1) : text.substring(0, currentCursor + 1);
	// will only get the first result
	const regex = new RegExp(chars, "g");
	const indexes = [];
	let result;
	// eslint-disable-next-line no-cond-assign
	while (result = regex.exec(textFromCursor)) {
		indexes.push(result.index);
		if (forward) break;
	}
	if (forward) return indexes.first();
	return indexes.last();
}

function handleJumpToRegex(forward, chars) {
	const currentView = app.workspace.getLeaf(false).view;
	const cm6Editor = currentView.editor.cm;
	// const { from, to } = cm6Editor.viewport;
	const text = cm6Editor.state.sliceDoc();

	// eslint-disable-next-line no-shadow
	const { editor } = currentView;
	// get index of current cursor
	const currentCursor = editor.posToOffset(editor.getCursor());
	const index = extractRegexp(text, chars, currentCursor, forward);

	if (!index) {
		new Notice("No result", 1000);
		return;
	}

	// move cursor to match
	if (forward) editor.setCursor(editor.offsetToPos(index + currentCursor + 1));
	else editor.setCursor(editor.offsetToPos(index));
}


// eslint-disable-next-line no-unused-vars
function moveToChars(forward) {
	const leaf = app.workspace.getLeaf(false);
	if (leaf.getViewState().type !== "markdown") return;
	const { contentEl } = leaf.view;
	const keyArray = [];
	const grabKey = (event) => {
		event.preventDefault();
		// handle Escape to reject the mode
		if (event.key === "Escape") contentEl.removeEventListener("keydown", grabKey, { capture: true });


		// test if keypress is capitalized
		if (/^[a-z]$/i.test(event.key)) {
			const isCapital = event.shiftKey;
			// capture uppercase
			if (isCapital) keyArray.push(event.key.toUpperCase());
			// capture lowercase
			else keyArray.push(event.key);
		}

		// stop when length of array is equal to 2
		if (keyArray.length === 2) {
			handleJumpToRegex(forward, keyArray.join(""));
			// removing eventListener after proceeded
			contentEl.removeEventListener("keydown", grabKey, { capture: true });
		}
	};
	contentEl.addEventListener("keydown", grabKey, { capture: true });

}
