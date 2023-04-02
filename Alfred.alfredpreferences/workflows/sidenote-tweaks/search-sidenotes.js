#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
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

const urlRegex = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/;

//──────────────────────────────────────────────────────────────────────────────

function run(argv) {
	const query = argv[0] ? argv[0].trim() : "";
	const ignoredTitle = $.getenv("ignored_title");

	const sidenotes = Application("SideNotes");
	const results = sidenotes
		.searchNotes(query)
		.filter(item => item.title !== ignoredTitle)
		.map(item => {
			const noteObj = getNoteObj(item.identifier);
			if (!noteObj) return false;
			const content = noteObj.text();
			console.log("content:", content);
			let icon = "";

			let type = noteObj.textFormatting();
			if (type === "markdown" && content.match(/\[[x ]\]/)) type = "tasklist";
			if (type === "code") icon += "👨‍💻";
			if (type === "tasklist") icon += "☑️ ";
			if (type === "plain") icon += "📃";

			if (content.includes("[img ")) icon += "🖼️ ";
			const urls = content.match(urlRegex);
			let urlSubtitle = "⌘: ";
			if (urls) {
				icon += "🔗";
				const isLinkOnlyNote = [item.title, item.details].includes(urls[0]);
				if (isLinkOnlyNote) urlSubtitle += "🗑🔗 Delete & Open ";
				else urlSubtitle += "🔗 Open ";
				urlSubtitle += urls[0];
			} else {
				urlSubtitle += "🚫 Note has no URL";
			}

			if (icon !== "") icon += " "; // padding
			return {
				title: item.title,
				subtitle: icon + item.details.slice(0, 100),
				match: alfredMatcher(item.title + item.details),
				arg: item.identifier,
				uid: item.identifier,
				mods: {
					alt: { arg: content },
					cmd: {
						subtitle: urlSubtitle,
						valid: Boolean(urls),
					},
				},
			};
		});

	// new note when none matching
	if (results.length === 0) {
		results.push({
			title: "New Sidenote: " + query,
			subtitle: "SideNotes Default Folder",
			arg: query,
			mods: {
				ctrl: { valid: false },
				alt: { valid: false },
				cmd: { valid: false },
			},
		});
	}

	return JSON.stringify({ items: results });
}
