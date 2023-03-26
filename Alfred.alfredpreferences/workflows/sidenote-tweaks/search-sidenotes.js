#!/usr/bin/env osascript -l JavaScript

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

function run(argv) {
	const query = argv[0];
	const sidenotes = Application("SideNotes");
	const results = sidenotes
		.search(query)
	for (let res of queryResults) {
		results.push({
			title: res.title,
			match: alfredMatcher(res.title) + " " alfredMatcher(res.details),
			subtitle: res.details,
			arg: res.identifier,
			uid: res.identifier,
		});
	}

	return JSON.stringify({ items: results });
}
