#!/usr/bin/env osascript -l JavaScript

const fileExists = filePath => Application("Finder").exists(Path(filePath));
const sidenotes = Application("SideNotes");

//──────────────────────────────────────────────────────────────────────────────

function run(argv) {
	const input = argv[0];

   // without the folder field, uses the setting from SideNotes to determine new
	// note location
	sidenotes.createNote({
		text: input,
		ispath: fileExists(input),
	});

	// close sidenotes
	Application("System Events").keystroke("w", { using: ["command down"] });

	const firstline = input.split("\n").shift();
	return firstline; // first line for Alfred notification
}
