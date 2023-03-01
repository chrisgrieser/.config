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

const jsonArray = app.doShellScript(`find "${snippetDir}" -type`)
	.split("")
	.map(item => {
		
		return {
			title: item,
			match: alfredMatcher(item),
			subtitle: item,
			type: "file:skipcheck",
			icon: { type: "fileicon", path: item },
			arg: item,
			uid: item,
		};
	});
JSON.stringify({ items: jsonArray });
