#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
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
	if (!query) return;

	const lang = $.getenv("language_code");
	const useWikiwand = $.getenv("use_wikiwand") === "1";

	// Wikiepdia Open Search API: https://www.mediawiki.org/wiki/API:Opensearch#JavaScript
	// API Sandbox: https://en.wikipedia.org/wiki/Special:ApiSandbox#action=opensearch&format=json&search=Hampi&namespace=0&limit=10&formatversion=2
	const maxResults = 9; // Alfred only shows 9 items at once
	const encodedQuery = encodeURIComponent(query);
	const wikipediaApiCall = `https://${lang}.wikipedia.org/w/api.php?action=opensearch&format=json&search=${encodedQuery}&namespace=0&limit=${maxResults}&profile=fuzzy`;
	const wikipediaItems = JSON.parse(httpRequest(wikipediaApiCall));

	/** @type AlfredItem[] */
	const wikipediaEntries = [];
	for (let i = 0; i < wikipediaItems[1].length; i++) {
		const suggestion = wikipediaItems[1][i];
		const desc = wikipediaItems[2][i];
		let url = wikipediaItems[3][i];
		if (useWikiwand) url = url.replace(/.*\/wiki\/(.+)/, `https://www.wikiwand.com/${lang}/$1`);

		wikipediaEntries.push({
			title: suggestion,
			subtitle: desc,
			quicklookurl: url, // used by AlfredExtraPane
			arg: url,
		});
	}

	return JSON.stringify({ items: wikipediaEntries });
}
