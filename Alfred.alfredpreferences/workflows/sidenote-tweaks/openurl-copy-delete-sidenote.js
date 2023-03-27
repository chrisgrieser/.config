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
	const doClose = mode.includes("close");

	// get content
	const sidenotes = Application("SideNotes");
	const curNote = sidenotes.currentNote();
	const content = curNote.text();

	// open URL (& close sidenotes)
	if (doOpenUrl) {
		// prettier-ignore
		const urlRegex = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/
		const urls = content.match(urlRegex);
		if (!urls) return "⚠️ No URL found."; // notification
		app.openLocation(urls[0]);

		// dynamically decide whether to delete
		const isLinkOnlyNote = [curNote.title(), curNote.details()].includes(urls[0]);
		doDelete = isLinkOnlyNote;
	}

	// Trash Note, but keep copy in trash folder
	if (doDelete) {
		const maxNameLen = 50;
		let safeTitle = curNote.title().replace(/[/\\:;,"'#()[\]=<>{}]|\.$/gm, "");
		if (safeTitle.length > maxNameLen) safeTitle = safeTitle.slice(0, maxNameLen);
		const trashNotePath = `${app.pathTo("home folder")}/.Trash/${safeTitle}.txt`;
		writeToFile(trashNotePath, content);
		sidenotes.currentNote().delete();
	}

	// close sidenotes
	if (doClose) {
		// apparently there is JXA API for it, therefore done via keystrokes since it
		// is ensured that SideNotes is the most frontmost app
		Application("System Events").keystroke("w", { using: ["command down"] });
	}

	// copy to clipboard
	if (doCopy) app.setTheClipboardTo(content);

	// returns are used for the notification
	if (doDelete && doOpenUrl) return "🗑 Note Deleted";
	else if (doCopy) return "✅ Copied";
	return ""; // don't create a notification
}
