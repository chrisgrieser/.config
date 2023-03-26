#!/usr/bin/env osascript -l JavaScript

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
}

const sidenotes = Application("SideNotes")

//──────────────────────────────────────────────────────────────────────────────

function run(argv) {
	const query = argv[0] ? argv[0].trim() : "";

	const results = sidenotes
		.searchNotes(query) // CAVEAT currently not possible to get the folder for a note
		.map(item => {
			const content = item.title + "\n" + item.details;
			const url = content.match(/https?:\/\/[^\s]+/);
			const icon = url ? "🔗 " : "";

			return {
				title: item.title,
				subtitle: icon + item.details,
				match: alfredMatcher(item.title + item.details),
				arg: item.identifier,
				uid: item.identifier,
				mods: {
					alt: { arg: content },
					cmd: {
						arg: url[0],
						subtitle: "⌘: Open first URL",
						valid: Boolean(url),
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
