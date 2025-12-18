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
function run() {
	const docsUrl = "https://api.github.com/repos/rvben/rumdl/git/trees/main?recursive=1";
	const baseUrl = "https://github.com/rvben/rumdl/tree/main/docs";

	const workArray = JSON.parse(httpRequest(docsUrl)).tree.flatMap(
		(/** @type {{ path: string; }} */ entry) => {
			const path = entry.path;
			const [_, page] = path.match(/\/(osx|common)\/([^/]+)\.md$/) || []
			if (!page) return [];

			const url = `${baseUrl}/${category}/${cli}`;

			return {
				title: cli,
				subtitle: category,
				mods: {
					cmd: { arg: cli }, // copy entry
				},
				arg: url,
				quicklookurl: url,
				uid: cli,
			};
		},
	);

	return JSON.stringify({
		items: workArray,
		cache: {
			seconds: 3600 * 24 * 7, // 7 days
			loosereload: true,
		},
	});
}
