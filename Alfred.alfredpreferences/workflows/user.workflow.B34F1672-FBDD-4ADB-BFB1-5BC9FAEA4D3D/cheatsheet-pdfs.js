#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

const cheatfolder = $.getenv("cheatfile_folder").replace(/^~/, app.pathTo("home folder"));

const jsonArray = app.doShellScript(`find "${cheatfolder}"`)
	.split("\r")
	.map(item => {
		const name = item.replace(/.*\//, "");
		return {
			"title": name,
			"subtitle": "cheatsheet",
			"match": alfredMatcher(item),
			"type": "file:skipcheck",
			"icon": {
				"type": "fileicon",
				"path": item
			},
			"arg": item,
			"uid": item,
		};
	});

JSON.stringify({ items: jsonArray });
