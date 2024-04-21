#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// INFO
// All available languages: https://devdocs.io/docs.json
// Search Index: https://documents.devdocs.io/javascript/index.json
// Data: https://documents.devdocs.io/javascript/db.json
// (source: https://github.com/luckasRanarison/nvim-devdocs)

/** @typedef {Object} DevDocsIndex
 * @property {{name: string, path: string, type: string}[]} entries
 * @property {{name: string, count: number, slug: string}[]} types
 */

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/** @type {Record<string, string>} */
const keywordLanguageMap = {
	js: "javascript",
	ts: "typescript",
	py: "python~3.12",
	lua: "lua~5.4",
};

/** @param {string} str */
function camelCaseMatch(str) {
	const subwords = str.replace(/[-_./]/g, " ");
	const fullword = str.replace(/[-_./]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [subwords, camelCaseSeparated, fullword, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const keyword = $.getenv("alfred_workflow_keyword");
	const language = keywordLanguageMap[keyword] || keyword;
	const indexUrl = `https://documents.devdocs.io/${language}/index.json`;

	/** @type {DevDocsIndex} */
	const response = JSON.parse(httpRequest(indexUrl));
	const items = response.entries.map((entry) => {
		const url = `https://devdocs.io/${language}/${entry.path}`;

		/** @type{AlfredItem} */
		const item = {
			title: entry.name,
			subtitle: entry.type,
			match: camelCaseMatch(entry.name),
			arg: url,
			uid: url,
		};
		return item;
	});

	return JSON.stringify({
		items: items,
		// cache: { seconds: 60 * 60 * 24, loosereload: true }, TODO
	});
}
