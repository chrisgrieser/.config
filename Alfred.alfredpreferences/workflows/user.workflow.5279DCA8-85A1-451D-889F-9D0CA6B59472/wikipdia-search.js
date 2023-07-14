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

const lang = $.getenv("language_code");
const useWikiwand = $.getenv("use_wikiwand") === "1"

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {

	const query = argv[0];
	if (!query) return;

	// Wikiepdia Open Search API: https://www.mediawiki.org/wiki/API:Opensearch#JavaScript
	// API Sandbox: https://en.wikipedia.org/wiki/Special:ApiSandbox#action=opensearch&format=json&search=Hampi&namespace=0&limit=10&formatversion=2
	const wikipediaApiCall = `https://${lang}.wikipedia.org/w/api.php?action=opensearch&format=json&search=${query}&namespace=0&limit=9&profile=fuzzy`;
	const wikipediaItems = JSON.parse(httpRequest(wikipediaApiCall));

	/** @type AlfredItem[] */
	const wikipediaEntries = [];
	for (let i = 0; i < wikipediaItems[1].length; i++) {
		const suggestion = wikipediaItems[1][i];
		const desc = wikipediaItems[2][i];
		const url = wikipediaItems[3][i];

		if (useWikiwand) url = `https://www.wikidata.org/wiki/${url}`;

		wikipediaEntries.push({
			title: suggestion,
			subtitle: desc,
			arg: url,
		});
	}

	return JSON.stringify({ items: wikipediaEntries });
}
