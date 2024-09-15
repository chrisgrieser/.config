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

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];

	// DOCS https://jisho.org/forum/54fefc1f6e73340b1f160000-is-there-any-kind-of-search-api
	const apiURL = "https://jisho.org/api/v1/search/words?keyword=";
	const response = JSON.parse(httpRequest(apiURL + encodeURIComponent(query)));

	/** @type {AlfredItem[]} */
	const items = response.data.map((/** @type {{name: string}} */ item) => {
		const { name } = item;
		

		/** @type {AlfredItem} */
		const alfredItem = {
			title: name,
			subtitle: name,
			arg: name,
		};
		return alfredItem;
	});

	return JSON.stringify({ items: items });
}
