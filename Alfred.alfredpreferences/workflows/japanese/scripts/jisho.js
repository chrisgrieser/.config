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

	/** @type {JishoResponse} */
	const response = JSON.parse(httpRequest(apiURL + encodeURIComponent(query)));

	/** @type {AlfredItem[]} */
	const items = response.data.map((item) => {
		const { japanese, senses, is_common } = item;

		const jap = `${japanese[0].word} 【${japanese[0].reading}】`;
		const eng = senses.map((sense) => sense.english_definitions[0]).join(", ");
		const url = "https://jisho.org/word/" + japanese[0].word;
		const icon = is_common ? "   ●" : "";

		/** @type {AlfredItem} */
		const alfredItem = {
			title: jap + icon,
			subtitle: eng,
			arg: url,
		};
		return alfredItem;
	});

	return JSON.stringify({ items: items });
}
