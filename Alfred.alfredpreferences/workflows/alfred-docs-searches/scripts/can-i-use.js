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

/** @param {string} str */
function camelCaseMatch(str) {
	const subwords = str.replace(/[-_./]/g, " ");
	const fullword = str.replace(/[-_./]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " ");
	return [subwords, camelCaseSeparated, fullword, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// DOCS docsurls
	const apiURL = "https://raw.githubusercontent.com/Fyrd/caniuse/main/fulldata-json/data-2.0.json";
	const response = JSON.parse(httpRequest(apiURL));

	/** @type AlfredItem[] */
	const entries = [];
	for (const [key, value] of Object.entries(response.data)) {
		const { title, categories, usage_perc_y } = value;
		const subtitle = `${categories.join(", ")}   ·   ${usage_perc_y}%`;
		const url = "https://caniuse.com/" + key;

		entries.push({
			title: title,
			match: camelCaseMatch(title),
			subtitle: subtitle,
			arg: url,
		});
	}

	return JSON.stringify({
		items: entries,
		cache: { seconds: 3600 * 24, loosereload: true },
	});
}
