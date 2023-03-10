#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

const jsonArray = $.getenv("text")
	.split("\n")
	.map(line => {
		return {
			title: line,
			subtitle: line,
			match: alfredMatcher(line),
			arg: line,
		};
	});

JSON.stringify({ items: jsonArray });
