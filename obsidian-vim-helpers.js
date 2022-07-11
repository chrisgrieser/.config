/* global app, editor, Notice */
//------------------------------------------------------------------------------

// g0 and g$
function movementHelper() {
	// eslint-disable-next-line no-shadow
	const editor = app.workspace.activeLeaf.view.editor;
	const pos = {
		from: editor.posToOffset(editor.getCursor("from")),
		to: editor.posToOffset(editor.getCursor("to")),
		head: editor.posToOffset(editor.getCursor("head")),
		anchor: editor.posToOffset(editor.getCursor("anchor")),
		empty: true
	};
	return pos;
}

// eslint-disable-next-line no-unused-vars
function goToEnd() {
	const pos = movementHelper();
	// move to end of visual line
	const endOfLine = editor.cm.moveToLineBoundary(pos, true);
	editor.setCursor(editor.offsetToPos(endOfLine.from - 1));
}

// eslint-disable-next-line no-unused-vars
function goToStart() {
	const pos = movementHelper();
	// move to beginning of visual line
	const startOfLine = editor.cm.moveToLineBoundary(pos, false);
	editor.setCursor(editor.offsetToPos(startOfLine.from));
}

//------------------------------------------------------------------------------
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
