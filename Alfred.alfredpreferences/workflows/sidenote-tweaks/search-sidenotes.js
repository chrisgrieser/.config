#!/usr/bin/env osascript -l JavaScript

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

function run(argv) {
	const query = argv[0] || "";
	const results = Application("SideNotes")
		.search(query)
		.filter(item => item.type !== "folder")
		.map(item => {
			return {
				title: item.title,
				subtitle: item.details,
				match: alfredMatcher(item.title + item.details),
				arg: item.identifier,
				uid: item.identifier,
			};
		});

	// new note when none matching
	if (results.length === 0) {
		results.push({
			title: "New Sidenote: " + query,
			arg: query,
		});
	}

	return JSON.stringify({ items: results });
}
