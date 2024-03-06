#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	const requestStr = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
	return requestStr;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	if (!query) {
		return JSON.stringify({
			items: [{ title: "Waiting for query…", valid: false }],
		});
	}

	// DOCS https://devterms.io/api/docs#tag/default/get/api/v1/search
	const apiURL = "https://devterms.io/api/v1/search?q=";
	const response = JSON.parse(httpRequest(apiURL + encodeURIComponent(query)));

	/** @type AlfredItem[] */
	const terms = response.hits.map(
		(
			/** @type {{ term: string; definition: string; example: string; id: string; url: string }} */ hit,
		) => {
			return {
				title: hit.term,
				subtitle: `${hit.definition} · ${hit.example}`,
				arg: hit.url,
				quicklookurl: hit.url,
				uid: hit.id,
			};
		},
	);

	return JSON.stringify({ items: terms });
}
