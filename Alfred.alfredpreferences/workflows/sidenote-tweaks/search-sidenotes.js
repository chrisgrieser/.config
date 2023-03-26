#!/usr/bin/env osascript -l JavaScript

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

function run(argv) {
	const query = argv[0] ? argv[0].trim() : "";

	const results = Application("SideNotes")
		.searchNotes(query)
		.map(item => {
			const content = item.title + "\n" + item.details;
			return {
				title: item.title,
				subtitle: item.details,
				match: alfredMatcher(item.title + item.details),
				arg: item.identifier,
				uid: item.identifier,
				mods: { alt: { arg: content } },
			};
		});

	// new note when none matching
	if (results.length === 0) {
		results.push({
			title: "New Sidenote: " + query,
			arg: query,
			mods: { alt: { valid: false } },
		});
	}

	return JSON.stringify({ items: results });
}
