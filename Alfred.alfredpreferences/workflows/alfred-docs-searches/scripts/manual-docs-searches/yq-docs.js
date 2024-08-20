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
function run() {
	const docsURL = "https://api.github.com/repos/mikefarah/yq/git/trees/master?recursive=1";
	const baseURL = "https://mikefarah.gitbook.io/yq";
	const docPathRegex = /^pkg\/yqlib\/doc\/(.*)\.md$/i;

	const workArray = JSON.parse(httpRequest(docsURL)).tree.map(
		(/** @type {{ path: string; }} */ entry) => {
			const subsite = entry.path.replace(docPathRegex, "$1");
			if (subsite === "header") return {}; // not real subpages
			const category = subsite.split("/")[0];
			const displayTitle = subsite.split("/")[1];
			const url = `${baseURL}/${subsite}`;

			return {
				title: displayTitle,
				subtitle: category,
				arg: url,
				quicklookurl: url,
				uid: subsite,
			};
		},
	);

	return JSON.stringify({
		items: workArray,
		//cache: { seconds: 3600 * 24 * 7 },
	});
}
