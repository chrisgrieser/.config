#!/usr/bin/env osascript -l JavaScript

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

const results = Application("SideNotes")
	.search("") // search for all notes and let Alfred to the filtering
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

JSON.stringify({ items: results });
