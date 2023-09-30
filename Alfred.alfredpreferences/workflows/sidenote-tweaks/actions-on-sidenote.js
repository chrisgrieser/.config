#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

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
	const folders = Application("SideNotes").folders;
	let noteObj;
	for (let i = 0; i < folders.length; i++) {
		const notesInFolder = folders[i].notes;
		for (let j = 0; j < notesInFolder.length; j++) {
			const note = notesInFolder[j];
			if (note.id() === noteId) {
				noteObj = note;
				break;
			}
		}
	}
	return noteObj;
}

function closeSideNotes() {
	// apparently there is no JXA API for it, therefore done via keystrokes
	// since it is already ensured that SideNotes is the most frontmost app
	Application("System Events").keystroke("w", { using: ["command down"] });
}

/**
 * Delete Note, but keep copy in archive folder instead of irreversibly removing it
 * @param {string} safeTitle
 * @param {SideNotesNote} noteObj
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
// biome-ignore lint/correctness/noUnusedVariables: argv
function run(argv) {
	const sidenotes = Application("SideNotes");

	// determine actions
	let doArchive = argv[0].includes("archive");
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
	const safeTitle = title
		.replaceAll("/", "-")
		.replace(/[\\$€§*#?!:;.,`'’‘"„“”«»’{}]/g, "")
		.replaceAll("&", "and")
		.replace(/ {2,}/g, " ")
		.slice(0, 50);

	//───────────────────────────────────────────────────────────────────────────

	if (doOpenUrl) {
		const urlRegex =
			/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/g;
		const urls = content.match(urlRegex);
		if (!urls) return "No URL found."; // notification
		closeSideNotes(); // needs to close before opening URL due to focus loss
		for (const url of urls) {
			app.openLocation(url);
		}

		// dynamically decide whether to archive the note
		const numberOfLines = details.split("\n").length;
		if (numberOfLines <= 2 && urls.length === 1) doArchive = true;
	}

	if (doArchive) archiveNote(noteObj, safeTitle);

	if (doCopy) {
		app.setTheClipboardTo(content);
		if (id === "current") closeSideNotes();
	}

	if (doExport) {
		if (id === "current") closeSideNotes();
		const exportPath = `${$.getenv("export_location")}/${safeTitle}.md`;
		writeToFile(exportPath, content);
		app.doShellScript(`open -R "${exportPath}"`);
	}

	// returns are used for the notification
	if (doArchive && doOpenUrl) return "🔗 Opened & Archived";
	else if (doCopy && doArchive) return "✅ Copied & Archived";
	else if (doCopy) return "✅ Copied";
	else if (doExport) return "✅ Exported";
	else if (doArchive) return "🗑 Note archived";
	return "";
}
