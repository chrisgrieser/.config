#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const fileExists = filePath => Application("Finder").exists(Path(filePath));

function run(argv) {
	const input = argv[0];
	const sidenotes = Application("SideNotes");
	const folder = sidenotes.folders.byName($.getenv("new_note_folder"));
	const isPath = fileExists(input);

	sidenotes.createNote({
		folder: folder,
		text: input,
		ispath: isPath,
	});

	const firstline = input.split("\n").shift();
	return firstline; // for notification
}
