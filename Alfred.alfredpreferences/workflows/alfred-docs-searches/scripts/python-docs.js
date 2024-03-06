#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\[\]]/g, " ");
	return [clean, str].join(" ");
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// INFO HOW TO UPDATE SEARCH INDEX
	// 1. Download it from https://docs.python.org/3/download.html
	// 2. Frm the search, fetch the file `searchindex.js` and put it under the
	// name below into this workflows `data` folder
	// 3. Append the python version for documentation purposes
	// TODO see how to automate this later
	const searchIndexFile = "./data/searchindex_python-3.12.2.js";

	const pythonVersion = searchIndexFile.match(/\d\.\d+/)[0];
	const baseUrl = `https://docs.python.org/${pythonVersion}/`;
	// `slice` to remove the `Search.setIndex(…)` enclosing the json we want
	const searchIndex = JSON.parse(readFile(searchIndexFile).slice(16, -1));

	const sites = [];
	for (const [entryTitle, entry] of Object.entries(searchIndex.indexentries)) {
		const [docId, documentTitle] = entry[0];
		const doc = searchIndex.docnames[docId];
		const url = baseUrl + doc + ".html#" + documentTitle;
		const [_, title, area] = entryTitle.match(/(\S+)(?: \((.*)\))?/) || ["", "", ""];

		sites.push({
			title: title,
			match: alfredMatcher(title),
			subtitle: area,
			arg: url,
		});
	}

	return JSON.stringify({
		items: sites,
		// 1 week (using our offline index, so it's always up to date)
		// cache: { seconds: 3600 * 24 * 7 },
	});
}
