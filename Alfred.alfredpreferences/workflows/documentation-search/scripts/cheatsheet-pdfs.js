#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

const cheatfolder = $.getenv("cheatfile_folder").replace(/^~/, app.pathTo("home folder"));

const jsonArray = app.doShellScript(`find "${cheatfolder}" -type f`)
	.split("\r")
	.map((/** @type {string} */ item) => {
		const name = item.replace(/.*\//, "");
		return {
			"title": name,
			"match": alfredMatcher(item),
			"type": "file:skipcheck",
			"arg": item,
			"uid": item,
		};
	});

JSON.stringify({ items: jsonArray });
