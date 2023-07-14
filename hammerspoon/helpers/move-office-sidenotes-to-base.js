#!/usr/bin/env osascript -l JavaScript
const fromFolder = "Office";
const toFolder = "Base";

//──────────────────────────────────────────────────────────────────────────────

const sidenotes = Application("SideNotes");
// @ts-ignore
const destination = sidenotes.folders.byName(toFolder);
// @ts-ignore
const notesToMove = sidenotes.folders.byName(fromFolder).notes;

const hasNotesToMove = notesToMove.length;

//──────────────────────────────────────────────────────────────────────────────

// loop backwards since deleting from array
// creating and deleting note since there does not seem to be a moving function
for (let i = notesToMove.length - 1; i >= 0; i--) {
	const note = notesToMove[i];

	sidenotes.createNote({
		// @ts-ignore
		folder: destination,
		text: note.text(),
	});

	note.delete();
}

//──────────────────────────────────────────────────────────────────────────────

// Open the Correct Folder
if (hasNotesToMove) {
	// @ts-ignore
	sidenotes.open(sidenotes.folders.byName(toFolder));
}
