#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
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
function getNoteObjAndFolder(noteId) {
	const sidenotes = Application("SideNotes");
	// @ts-ignore
	const folders = sidenotes.folders;
	for (let i = 0; i < folders.length; i++) {
		const notesInFolder = folders[i].notes;
		for (let j = 0; j < notesInFolder.length; j++) {
			const note = notesInFolder[j];
			if (note.id() === noteId)
				return {
					noteObj: note,
					folder: folders[i].name(),
				};
		}
	}
	return null;
}

const urlRegex =
	/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/g;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables: Alfred
function run(argv) {
	const query = argv[0].match(/^\s*$/) ? "" : argv[0];
	const sidenotes = Application("SideNotes");

	const ignoredFolder = $.getenv("ignored_folder");
	const baseFolder = $.getenv("base_folder");

	const results = sidenotes
		// @ts-ignore
		.searchNotes(query)
		.map((/** @type {{ identifier: string; title: string; details: string; }} */ item) => {
			const temp = getNoteObjAndFolder(item.identifier);
			if (!temp) return;
			const foldername = temp.folder;
			const noteObj = temp.noteObj;
			const content = noteObj.text();
			const numberOfLines = content.split("\n").length;
			const secondLine = content.split("\n")[1] || "";
			let icon = "";

			let type = noteObj.textFormatting();
			if (type === "markdown" && content.match(/\[[ x]\]/)) type = "tasklist";
			if (type === "code") icon += "👨‍💻";
			if (type === "tasklist") icon += "☑️ ";
			if (type === "plain") icon += "📃";

			if (content.includes("[img ")) icon += "🖼️ ";
			const urls = content.match(urlRegex);
			let urlSubtitle = "⌘: ";
			if (urls) {
				icon += "🔗";

				// set url subtitle the same way `actions-on-sidenote` will act
				if (numberOfLines <= 2 && urls.length === 1) urlSubtitle += "🗑🔗 Archive & Open ";
				else urlSubtitle += "🔗 Open ";
				urlSubtitle += urls[0];
			} else {
				urlSubtitle += "🚫 Note has no URL";
			}
			if (icon !== "") icon += " "; // padding

			const folderSub = foldername === baseFolder ? "" : `[📂 ${foldername}] `;
			const subtitle = folderSub + icon + secondLine;

			return {
				title: item.title,
				subtitle: subtitle,
				match: alfredMatcher(item.title + " " + item.details),
				arg: item.identifier,
				uid: item.identifier,
				mods: {
					alt: { arg: content },
					cmd: {
						subtitle: urlSubtitle,
						valid: Boolean(urls),
					},
				},
				folder: foldername, // only set to filter afterwards
			};
		})
		.filter((/** @type {{ folder: string; }} */ item) => item.folder !== ignoredFolder);

	// new note
	if (query.length > 3 || results.length === 0) {
		results.push({
			title: " 🆕 New Sidenote: " + query,
			arg: query,
			mods: { ctrl: { valid: false }, alt: { valid: false }, cmd: { valid: false } },
		});
	}

	return JSON.stringify({ items: results });
}
