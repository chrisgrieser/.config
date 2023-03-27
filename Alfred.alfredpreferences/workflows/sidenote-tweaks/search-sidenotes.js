#!/usr/bin/env osascript -l JavaScript

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
}

const sidenotes = Application("SideNotes");

//──────────────────────────────────────────────────────────────────────────────

// TODO generate array of notes *objects* with their properties note objects seem 
// to be retrievable via by supplying noteid *and* folderid:
// `Application("SideNotes").folders.byId("35BE5A12-DAF4-44FD-AF7D-2689CBB14BF3").notes.byId("0776263A-77FA-41EF-808E-6266C77DBDF9")`
// `Application("SideNotes").currentNote()` retrieves a note that way. This
// allows for retrieving notes via ID, when iterating folders *and* notes 🙈
// Note Objects have more properties (see Script Editor Dictionary) and also
// also methods like `.delete()`

//──────────────────────────────────────────────────────────────────────────────

function run(argv) {
	const query = argv[0] ? argv[0].trim() : "";

	const results = sidenotes
		.searchNotes(query) // CAVEAT currently not possible to get the folder for a note
		.map(item => {
			const content = item.title + "\n" + item.details;

			// prettier-ignore
			const urlRegex = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/
			const urls = content.match(urlRegex);

			let urlSubtitle = "";
			let icon = "";
			if (content.includes("☐") || content.includes("☑")) icon += "☑️";
			if (urls) {
				icon += "🔗";
				urlSubtitle = "⌘: ";
				const isLinkOnlyNote = [item.title, item.details].includes(urls[0]);
				if (isLinkOnlyNote) urlSubtitle += "🗑🔗 Delete & Open ";
				else urlSubtitle += "🔗 Open ";
				urlSubtitle += urls[0];
			}
			if (icon) icon += " "; // padding

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
		results.push({
			title: "New Sidenote: " + query,
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
