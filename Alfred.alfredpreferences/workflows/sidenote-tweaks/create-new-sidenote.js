#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;
ObjC.import("stdlib");
const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));
const sidenotes = Application("SideNotes");

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables: Alfred
function run(argv) {
	const input = argv[0];
	const baseFolder = sidenotes.folders.byName($.getenv("base_folder"));

	// without the folder field, uses the setting from SideNotes to determine new
	// note location
	sidenotes.createNote({
		text: input,
		folder: baseFolder,
		ispath: fileExists(input),
	});

	// close sidenotes
	Application("System Events").keystroke("w", { using: ["command down"] });

	const firstline = input.split("\n").shift();
	return firstline; // for Alfred notification
}
