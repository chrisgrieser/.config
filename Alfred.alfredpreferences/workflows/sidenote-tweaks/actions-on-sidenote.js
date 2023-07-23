#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

const urlRegex =
	/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/g;
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

/** @param {string} noteId */
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

function closeSideNotes() {
	// apparently there is no JXA API for it, therefore done via keystrokes
	// since it is ensured that SideNotes is the most frontmost app
	Application("System Events").keystroke("w", { using: ["command down"] });
}

/**
 * Delete Note, but keep copy in archive folder instead of irreversibly removing it
 * @param {{safeTitle: any;text: () => string;delete: () => void;}} noteObj
 * @param {string} safeTitle
 */
function archiveNote(noteObj, safeTitle) {
	const content = noteObj.text().trim();
	noteObj.delete();
	if (!content) return; // empty notes do not need to be archived

	const archiveLocation = $.getenv("archive_location").replace(/^~/, app.pathTo("home folder"));
	const archivePath = `${archiveLocation}/${safeTitle}.md`;
	writeToFile(archivePath, content);
}

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables: argv
function run(argv) {
	const sidenotes = Application("SideNotes");

	// determine actions
	const doArchive = argv[0].includes("archive");
	const doOpenUrl = argv[0].includes("openurl");
	const doCopy = argv[0].includes("copy");
	const doExport = argv[0].includes("export");

	// determine note
	const id = $.getenv("note_id");
	const noteObj = id === "current" ? sidenotes.currentNote() : getNoteObj(id);

	// get note properties
	const content = noteObj.text(); // full content
	const details = noteObj.content(); // content without title
	const title = noteObj.title().trim();
	let safeTitle = title.replace(/[/\\:;,"'#()[\]=<>{}?!|§]|\.$/gm, "-");
	if (safeTitle.length > maxNameLen) safeTitle = safeTitle.slice(0, maxNameLen);

	//───────────────────────────────────────────────────────────────────────────

	if (doOpenUrl) {
		const urls = content.match(urlRegex);
		if (!urls) return "⚠️ No URL found."; // notification
		closeSideNotes(); // needs to close before opening URL due to focus loss
		urls.forEach((/** @type {string} */ url) => app.openLocation(url));

		// dynamically decide whether to delete note
		const numberOfLines = details.split("\n").length
		if (numberOfLines <= 2 && urls.length === 1) archiveNote(noteObj, safeTitle);
	}

	if (doArchive) archiveNote(noteObj, safeTitle);

	if (doCopy) app.setTheClipboardTo(content);

	if (doExport) {
		// ensure line breaks before headings
		// (sometimes skipped since SideNotes UI makes it not apparent)
		const exportContent = content.replace(/\n+(?=#+ )/g, "\n\n");

		const exportPath = `${exportFolder}/${safeTitle}.md`;
		writeToFile(exportPath, exportContent);
		app.doShellScript(`open -R "${exportPath}"`);
	}

	if (doCopy && id === "current") closeSideNotes();

	// returns are used for the notification
	if (doArchive && doOpenUrl) return "🔗 Opened & Archived";
	else if (doCopy && doArchive) return "✅ Copied & Archived";
	else if (doCopy) return "✅ Copied";
	else if (doExport) return "✅ Exported";
	else if (doArchive) return "🗑 Note archived";
	return "";
}
