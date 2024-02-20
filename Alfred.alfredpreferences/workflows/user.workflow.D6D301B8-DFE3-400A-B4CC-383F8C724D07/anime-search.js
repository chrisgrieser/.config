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
function run(argv){
	const apiURL = "https://api.jikan.moe/v4/anime?q="

	const query = argv[0]
	/** @type AlfredItem[] */
	const animeTitles = httpRequest(apiURL + encodeURIComponent(query))
		.split("\n")
		.map(anime => {
			
			return {
				title: anime,
				subtitle: anime,
				arg: anime,
			};
		});
	return JSON.stringify({ items: animeTitles });
}
