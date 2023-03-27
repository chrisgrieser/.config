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
	let doDelete = argv[0].includes("delete");
	const doOpenUrl = argv[0].includes("openurl");
	const doCopy = argv[0].includes("copy");
	const doClose = argv[0].includes("close");

	// get content
	const sidenotes = Application("SideNotes");
	const curNote = sidenotes.currentNote();
	const content = curNote.text();
	const details = content.split("\n")[1];
	const title = curNote.title();

	// open URL (& close sidenotes)
	if (doOpenUrl) {
		// prettier-ignore
		const urlRegex = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/
		const urls = content.match(urlRegex);
		if (!urls) return "⚠️ No URL found."; // notification
		app.openLocation(urls[0]);

		// dynamically decide whether to delete
		const isLinkOnlyNote = [title, details].includes(urls[0]);
		doDelete = isLinkOnlyNote;
	}

	// Delete Note, but keep copy in trash instead of irreversibly removing it
	if (doDelete) {
		const maxNameLen = 50;
		let safeTitle = title.replace(/[/\\:;,"'#()[\]=<>{}]|\.$/gm, "");
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
