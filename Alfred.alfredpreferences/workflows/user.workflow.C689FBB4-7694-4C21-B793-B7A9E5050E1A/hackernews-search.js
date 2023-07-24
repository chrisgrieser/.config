#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	if (!query) {
		return JSON.stringify({
			items: [ { title: "Waiting for query…", valid: false } ],
		});
	}
	const apiUrl = "https://hn.algolia.com/api/v1/search?query=";

	/** @type AlfredItem[] */
	const news = JSON.parse(httpRequest(apiUrl + query)).hits.map((hit) => {
		const hackernewsUrl = "https://news.ycombinator.com/item?id=" + hit.objectID;
		const externalUrl = hit.url || hit.story_url || hackernewsUrl;
		const comments = hit.num_comments ? ` (${hit.num_comments})` : "";
		const subtitle = `${hit.points}${comments}  ·  ${externalUrl}`;

		return {
			title: hit.title,
			subtitle: subtitle,
			arg: hackernewsUrl,
			mods: {
				cmd: {
					arg: hackernewsUrl,
				},
			},
		};
	});
	return JSON.stringify({ items: news });
}
