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
			const path = entry.path;
			if (
				!docPathRegex.test(path) ||
				path.includes("/headers/") ||
				path.endsWith("notification-snippet.md")
			) {
				return {};
			}

			const subsite = path.replace(docPathRegex, "$1");
			const [category, title] = subsite.split("/");
			const url = `${baseURL}/${subsite}`;

			return {
				title: title.replaceAll("-", " "),
				subtitle: category,
				mods: {
					cmd: { arg: title }, // copy entry
				},
				arg: url,
				quicklookurl: url,
				uid: subsite,
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
