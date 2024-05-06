#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// DOCS docsurls
	const apiURL = "https://raw.githubusercontent.com/Fyrd/caniuse/main/fulldata-json/data-2.0.json";
	const response = JSON.parse(httpRequest(apiURL));

	/** @type AlfredItem[] */
	const entries = [];
	for (const [_, value] of Object.entries(response.data)) {
		const { title, categories } = value;
		const categoryInfo = categories.join(", ");
		entries.push({
			title: title,
			subtitle: categoryInfo,
			arg: title,
		});
	}

	return JSON.stringify({
		items: entries,
		// cache: { seconds: 600, loosereload: true },
	});
}
