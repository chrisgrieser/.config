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
	// INFO 
	// see the file `.data/HOWTO_update-python-searchindex` on how to update the index
	const searchIndexFile = "./data/searchindex_python-3.12.2.json";

	const pythonVersion = searchIndexFile.match(/\d\.\d+/)[0];
	const baseUrl = `https://docs.python.org/${pythonVersion}/`;
	const searchIndex = JSON.parse(readFile(searchIndexFile));

	const sites = [];
	for (const [entryTitle, entry] of Object.entries(searchIndex.indexentries)) {
		const [docId, documentTitle] = entry[0];
		const doc = searchIndex.docnames[docId];
		const url = baseUrl + doc + ".html#" + documentTitle;
		const [full, area] = entryTitle.match(/ \((.+)\)$/) || [];
		const title = area ? entryTitle.slice(0, -full.length) : entryTitle;

		let matcher = alfredMatcher(title);
		if (area) matcher += " " + alfredMatcher(area);

		sites.push({
			title: title,
			match: matcher,
			subtitle: area,
			arg: url,
			quicklookurl: url,
			uid: url,
		});
	}

	return JSON.stringify({
		items: sites,
		// 1 week (using our offline index, so it's always up to date)
		cache: { seconds: 3600 * 24 * 7 },
	});
}
