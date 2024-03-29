#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const jsonPath =
		$.getenv("alfred_preferences") +
		"/workflows/" +
		$.getenv("alfred_workflow_uid") +
		"/data/named-css-colors.json";
	const colors = JSON.parse(readFile(jsonPath));

	/** @type AlfredItem[] */
	const items = [];
	for (const [name, hex] of Object.entries(colors)) {
		items.push({
			title: name,
			subtitle: hex,
			arg: name,
		});
	}

	return JSON.stringify({
		items: items,
		cache: {
			seconds: 36000,
		},
	});
}
