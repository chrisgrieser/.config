#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function writeToFile(file, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(file, true, $.NSUTF8StringEncoding, null);
}

const urlRegex = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/;
const exportFolder = $.getenv("export_folder").replace(/^~/, app.pathTo("home folder"));
const maxNameLen = 50;

//──────────────────────────────────────────────────────────────────────────────

// HACK since notes are not directly accessible via their id, but only from
// inside a folder: `Application("SideNotes").folders.byId("35BE5A12-DAF4-44FD-AF7D-2689CBB14BF3").notes.byId("0776263A-77FA-41EF-808E-6266C77DBDF9")`
// `Application("SideNotes").currentNote()` retrieves a note that way. This
// necessitates iterating folders *and* notes to retrieve them by ID. However,
// note objects have more properties like textFormatting, the `.text()` method
// includes information on whether the note has an image, and methods like
// `.delete()` are available
function getNoteObj(noteId) {
	const sidenotes = Application("SideNotes");
	const folders = sidenotes.folders;
	for (let i = 0; i < folders.length; i++) {
		const notesInFolder = folders[i].notes;
		for (let j = 0; j < notesInFolder.length; j++) {
			const note = notesInFolder[j];
			if (note.id() === noteId) return note;
		}
	}
	return false;
}

//──────────────────────────────────────────────────────────────────────────────

/* eslint-disable-next-line complexity */
function run(argv) {
	const sidenotes = Application("SideNotes");

	// determine actions
	let doDelete = argv[0].includes("delete");
	const doOpenUrl = argv[0].includes("openurl");
	const doCopy = argv[0].includes("copy");
	const doExport = argv[0].includes("export");

	// determine note
	const id = $.getenv("note_id");
	const noteObj = id === "current" ? sidenotes.currentNote() : getNoteObj(id);

	// get content
	const content = noteObj.text(); // full content
	const details = noteObj.content(); // content without title
	const title = noteObj.title().trim();
	let safeTitle = title.replace(/[/\\:;,"'#()[\]=<>{}?!|§]|\.$/gm, "-");
	if (safeTitle.length > maxNameLen) safeTitle = safeTitle.slice(0, maxNameLen);

	// open URL (& close sidenotes)
	if (doOpenUrl) {
		const urls = content.match(urlRegex);
		if (!urls) return "⚠️ No URL found."; // notification
		app.openLocation(urls[0]);
		const secondLine = details.split("\n")[0].trim();

		// dynamically decide whether to delete
		const isLinkOnlyNote = [title, secondLine].includes(urls[0]);
		doDelete = isLinkOnlyNote;
	}

	// Delete Note, but keep copy in trash instead of irreversibly removing it
	if (doDelete) {
		const trashNotePath = `${app.pathTo("home folder")}/.Trash/${safeTitle}.md`;
		writeToFile(trashNotePath, content);
		noteObj.delete();
	}

	// copy to clipboard
	if (doCopy) app.setTheClipboardTo(content);

	if (doExport) {
		const exportPath = `${exportFolder}/${safeTitle}.md`;
		writeToFile(exportPath, content);
		app.doShellScript(`open -R "${exportPath}"`);
	}

	if (doCopy && id === "current") {
		// apparently there is no JXA API for it, therefore done via keystrokes
		// since it is ensured that SideNotes is the most frontmost app
		delay(0.05); /* eslint-disable-line no-magic-numbers */
		Application("System Events").keystroke("w", { using: ["command down"] });
	}

	// returns are used for the notification
	if (doDelete && doOpenUrl) return "🔗 Opened & Deleted";
	else if (doCopy && doDelete) return "✅ Copied & Deleted";
	else if (doCopy) return "✅ Copied";
	else if (doExport) return "✅ Exported";
	else if (doDelete) return "🗑 Note Deleted";
	return "";
}
