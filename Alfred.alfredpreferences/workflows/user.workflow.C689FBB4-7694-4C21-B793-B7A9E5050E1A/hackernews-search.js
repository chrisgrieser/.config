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

	// INFO if no query, return nothing -> show the hackernews top stories instead
	if (!query) return "{}";

	const searchApi = "https://hn.algolia.com/api/v1/search?query=";

	/** @type AlfredItem[] */
	const news = JSON.parse(httpRequest(searchApi + query)).hits.map(
		(
			/** @type {{ created_at: string; objectID: string | number; url: any; story_url: any; num_comments: any; points: any; title: any; story_title: any; }} */ hit,
		) => {
			const useDstillAi = $.getenv("USE_DSTILL_AI") === "1";
			const year = hit.created_at.substring(0, 4);
			const baseUrl = useDstillAi
				? "https://dstill.ai/hackernews/item/"
				: "https://news.ycombinator.com/item?id=";
			const hackernewsUrl = baseUrl + hit.objectID;
			const externalUrl = hit.url || hit.story_url || hackernewsUrl;
			const comments = hit.num_comments ? `  |  •${hit.num_comments}` : "";
			const subtitle = `▲${hit.points}${comments}  |  ${year}`;
			const title = hit.title || hit.story_title;

			return {
				title: title,
				subtitle: subtitle,
				arg: hackernewsUrl,
				mods: {
					cmd: {
						arg: externalUrl,
					},
				},
			};
		},
	);
	return JSON.stringify({ items: news });
}
