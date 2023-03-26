#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function writeToFile(file, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(file, true, $.NSUTF8StringEncoding, null);
}
//──────────────────────────────────────────────────────────────────────────────

function run(argv) {
	const mode = argv[0];

	// get content
	const sidenotes = Application("SideNotes");
	const currentNote = sidenotes.currentNote();
	const content = currentNote.text();

	if (mode.includes("openurl")) {

	}
	const url = content.match(/https?:\/\/[^\s]+/)[0];

	// close sidenotes
	Application("System Events").keystroke("w", { using: ["command down"] });

	// Trash Note, but keep copy in trash folder
	const maxNameLen = 50;
	let safeTitle = sidenotes
		.currentNote()
		.title()
		.replace(/[/\\:;,"'#()[\]=<>{}]/gm, "");
	if (safeTitle.length > maxNameLen) safeTitle = safeTitle.slice(0, maxNameLen);
	const trashNotePath = `${app.pathTo("home folder")}/.Trash/${safeTitle}.txt`;
	writeToFile(trashNotePath, content);
	sidenotes.currentNote().delete();

	// (optional) copy to clipboard
	if (mode === "copy-delete") app.setTheClipboardTo(content);
}
