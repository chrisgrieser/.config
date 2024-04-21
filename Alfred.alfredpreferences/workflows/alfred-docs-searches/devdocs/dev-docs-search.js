#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// INFO
// All available languages: https://devdocs.io/docs.json
// Search Index: https://documents.devdocs.io/javascript/index.json
// Data: https://documents.devdocs.io/javascript/db.json
// However, all these seem undocumented. (source: https://github.com/luckasRanarison/nvim-devdocs)

/** @typedef {Object} DevDocsIndex
 * @property {{name: string, path: string, type: string}[]} entries
 * @property {{name: string, count: number, slug: string}[]} types
 */

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/** @param {string} str */
function camelCaseMatch(str) {
	const subwords = str.replace(/[-_./]/g, " ");
	const fullword = str.replace(/[-_./]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [subwords, camelCaseSeparated, fullword, str].join(" ") + " ";
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const keyword = $.getenv("alfred_workflow_keyword");
	const keywordLanguageMap = JSON.parse(readFile("./devdocs/keyword-slug-map.json"));
	const language = keywordLanguageMap[keyword];
	const iconpath = `./devdocs/icons/${keyword}.png`;
	const iconExists = fileExists(iconpath);

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
			quicklookurl: url,
			arg: url,
			uid: url,
		};

		// icon defaults to devdocs icon
		if (iconExists) item.icon = { path: iconpath };

		return item;
	});

	// CAVEAT cannot use Alfred cache, since it would cache results for different keywords
	return JSON.stringify({ items: items });
}
