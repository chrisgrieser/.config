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
	// determine actions
	const mode = argv[0];
	let doDelete = mode.includes("delete");
	const doOpenUrl = mode.includes("openurl");
	const doCopy = mode.includes("copy");

	// get content
	const sidenotes = Application("SideNotes");
	const currentNote = sidenotes.currentNote();
	const content = currentNote.text();

	// open URL (& close sidenotes)
	if (doOpenUrl) {
		const url = content.match(/https?:\/\/[^\s]+/)[0];
		app.openLocation(url);

		// close sidenotes
		Application("System Events").keystroke("w", { using: ["command down"] });

		// dynamically decide whether to delete
		const noteHasOnlyUrl = content === url;
		const secondLineOnlyUrl = content.split("\n")[1] === url;
		doDelete = noteHasOnlyUrl || secondLineOnlyUrl;
	}

	// Trash Note, but keep copy in trash folder
	if (doDelete) {
		const maxNameLen = 50;
		let safeTitle = sidenotes
			.currentNote()
			.title()
			.replace(/[/\\:;,"'#()[\]=<>{}]/gm, "");
		if (safeTitle.length > maxNameLen) safeTitle = safeTitle.slice(0, maxNameLen);
		const trashNotePath = `${app.pathTo("home folder")}/.Trash/${safeTitle}.txt`;
		writeToFile(trashNotePath, content);
		sidenotes.currentNote().delete();
	}

	// (optional) copy to clipboard
	if (doCopy) {
		app.setTheClipboardTo(content);
	}

	if (doCopy || doOpenUrl)
}
