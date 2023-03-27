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
	const firstLine = currentNote.title();

	// open URL (& close sidenotes)
	if (doOpenUrl) {
		// prettier-ignore
		const urlRegex = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/
		const url = content.match(urlRegex);
		if (!url) return "⚠️ No URL found.";  // notification
		app.openLocation(url[0]);

		// dynamically decide whether to delete
		const noteHasOnlyUrl = content === url;
		const secondLineOnlyUrl = content.split("\n")[1] === url;
		doDelete = noteHasOnlyUrl || secondLineOnlyUrl;
	}

	// Trash Note, but keep copy in trash folder
	if (doDelete) {
		const maxNameLen = 50;
		let safeTitle = firstLine.replace(/[/\\:;,"'#()[\]=<>{}]|\.$/gm, "");
		if (safeTitle.length > maxNameLen) safeTitle = safeTitle.slice(0, maxNameLen);
		const trashNotePath = `${app.pathTo("home folder")}/.Trash/${safeTitle}.txt`;
		writeToFile(trashNotePath, content);
		sidenotes.currentNote().delete();
	}

	// close sidenotes
	if (doCopy || doOpenUrl) {
		Application("System Events").keystroke("w", { using: ["command down"] });
	}

	// copy to clipboard
	if (doCopy) {
		app.setTheClipboardTo(content);
		return "✅ Copied"; // for notification
	}
	return ""; // don't create a notification
}
