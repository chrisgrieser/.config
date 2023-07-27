#!/usr/bin/env osascript -l JavaScript
const fromFolder = "Office";
const toFolder = "Base";

//──────────────────────────────────────────────────────────────────────────────

const sidenotes = Application("SideNotes");
const destination = sidenotes.folders.byName(toFolder);
const notesToMove = sidenotes.folders.byName(fromFolder).notes;

const hasNotesToMove = notesToMove.length;

//──────────────────────────────────────────────────────────────────────────────

// loop backwards since deleting from array
// creating and deleting note since there does not seem to be a moving function
for (let i = notesToMove.length - 1; i >= 0; i--) {
	const note = notesToMove[i];

	sidenotes.createNote({
		folder: destination,
		text: note.text(),
	});

	note.delete();
}

//──────────────────────────────────────────────────────────────────────────────

// Open the Correct Folder
if (hasNotesToMove) {
	sidenotes.open(sidenotes.folders.byName(toFolder));
}
