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

const snippetDir = $.getenv("snippetDir").replace(/^~/, app.pathTo("home folder"));
const jsonArray = app.doShellScript(`find "${snippetDir}" -type f -name "*.json"`)
	.split("\r")
	.map(fPath => {
		const parts = fPath.split("/")
		const fileName = parts.pop().slice(0, -5);
		const 
		
		return {
			title: item,
			match: alfredMatcher(item),
			subtitle: item,
			arg: item,
			uid: item,
		};
	});
JSON.stringify({ items: jsonArray });
