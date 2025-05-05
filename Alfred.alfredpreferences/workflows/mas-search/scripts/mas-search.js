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

	// DOCS docsurls
	const apiURL = "URL" + encodeURIComponent(query);
	const response = JSON.parse(httpRequest(apiURL));

	/** @type {AlfredItem[]} */
	const items = response.data.map((/** @type {{name: string}} */ item) => {
		const { name } = item;
		

		/** @type {AlfredItem} */
		const alfredItem = {
			title: name,
			subtitle: name,
			arg: name,
			quicklookurl: name,
		};
		return alfredItem;
	});

	return JSON.stringify({ items: items });
}
