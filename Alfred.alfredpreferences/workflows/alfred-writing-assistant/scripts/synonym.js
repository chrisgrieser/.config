#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = encodeURIComponent(argv[0]);

	// DOCS https://www.datamuse.com/api/
	const response = httpRequest("https://api.datamuse.com/words?rel_syn=" + query);

	const synonyms = JSON.parse(response).map(
		(/** @type {{ word: string; score: number; }} */ item) => {
			return {
				title: item.word,
				subtitle: item.score,
				arg: item.word,
			};
		},
	);

	return JSON.stringify({ items: synonyms });
}
