#!/usr/bin/env osascript -l JavaScript

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

// TODO generate array of notes *objects* with their properties note objects seem
// to be retrievable via by supplying noteid *and* folderid:
// `Application("SideNotes").folders.byId("35BE5A12-DAF4-44FD-AF7D-2689CBB14BF3").notes.byId("0776263A-77FA-41EF-808E-6266C77DBDF9")`
// `Application("SideNotes").currentNote()` retrieves a note that way. This
// allows for retrieving notes via ID, when iterating folders *and* notes 🙈
// Note Objects have more properties (see Script Editor Dictionary) and also
// also methods like `.delete()`

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

	const sidenotes = Application("SideNotes");
	const results = sidenotes
		.searchNotes(query) // CAVEAT currently not possible to get the folder for a note
		.map(item => {
			const noteObj = getNoteObj(item.identifier);
			if (!noteObj) return false;
			const content = noteObj.text();

			let icon = "";

			let type = noteObj.textFormatting();
			if (type === "markdown" && content.match(/☐|☑/)) type = "tasklist";
			if (type === "code") icon += "👨‍💻";
			if (type === "tasklist") icon += "☑️ ";
			if (type === "plain") icon += "📃";

			if (content.includes("[img ")) icon += "🖼️ ";
			const urls = content.match(urlRegex);
			let urlSubtitle;
			if (urls) {
				icon += "🔗";
				urlSubtitle = "⌘: ";
				const isLinkOnlyNote = [item.title, item.details].includes(urls[0]);
				if (isLinkOnlyNote) urlSubtitle += "🗑🔗 Delete & Open ";
				else urlSubtitle += "🔗 Open ";
				urlSubtitle += urls[0];
			} else {
				urlSubtitle = "🚫 Note has no URL.";
			}

			if (icon !== "") icon += " "; // padding
			return {
				title: item.title,
				subtitle: icon + item.details,
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
		const currentFolder = sidenotes.currentFolder().name();
		results.push({
			title: "New Sidenote: " + query,
			subtitle: `📂 ${currentFolder}`,
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
