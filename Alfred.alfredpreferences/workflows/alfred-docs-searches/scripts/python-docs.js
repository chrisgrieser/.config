#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ");
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
	const pythonVersion = "3.12";
	const baseUrl = `https://docs.python.org/${pythonVersion}/library/`;

	const searchIndexFile =
		"/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/File Hub/python-3.12.2-docs-html/searchindex.json";
	const searchIndex = JSON.parse(readFile(searchIndexFile));

	const sites = [];
	for (const [title, entry] of Object.entries(searchIndex.indexentries)) {
		const [docId, documentTitle] = entry[0];
		const doc = searchIndex.documents[docId];
		sites.push({
			title: title,
			subtitle: documentTitle + " - " + docId,
		});
	}

	return JSON.stringify({
		items: sites,
		// cache: { seconds: 3600 * 24 * 7 * 4 },
	});
}
