#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

let first = true;
const jsonArray = $.getenv("text")
	.split("\n")
	.map(line => {
		const subtitle = first ? "⌘: Multi-Select" : "";
		first = false;
		
		return {
			title: line,
			subtitle: subtitle,
			match: alfredMatcher(line),
			arg: line,
		};
	});

JSON.stringify({ items: jsonArray });
