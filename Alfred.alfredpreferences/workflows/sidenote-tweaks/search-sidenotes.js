#!/usr/bin/env osascript -l JavaScript

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
}

const sidenotes = Application("SideNotes");

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
			const firstUrl = urls ? urls[0] : null;
			const icon = urls ? "🔗 " : "";

			return {
				title: item.title,
				subtitle: icon + item.details,
				match: alfredMatcher(item.title + item.details),
				arg: item.identifier,
				uid: item.identifier,
				mods: {
					alt: { arg: content },
					cmd: {
						arg: firstUrl,
						subtitle: "⌘: Open first URL",
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
				alt: { valid: false },
				cmd: { valid: false },
			},
		});
	}

	return JSON.stringify({ items: results });
}
