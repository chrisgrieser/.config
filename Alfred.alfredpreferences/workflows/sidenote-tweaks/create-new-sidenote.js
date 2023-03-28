#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const fileExists = filePath => Application("Finder").exists(Path(filePath));
const sidenotes = Application("SideNotes");

//──────────────────────────────────────────────────────────────────────────────

function run(argv) {
	const input = argv[0];

	sidenotes.createNote({
		text: input,
		folder: sidenotes.currentFolder(),
		ispath: fileExists(input),
	});

	// close sidenotes
	Application("System Events").keystroke("w", { using: ["command down"] });

	// send first line to Alfred notification
	const firstline = input.split("\n").shift();
	return firstline;
}
