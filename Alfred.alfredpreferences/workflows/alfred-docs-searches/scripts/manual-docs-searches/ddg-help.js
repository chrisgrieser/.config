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

/** @param {string} str @return {string} */
function prettyString(str) {
	const capitalized = str.charAt(0).toUpperCase() + str.slice(1);
	return capitalized.replaceAll("-", " ");
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const docsURL =
		"https://api.github.com/repos/duckduckgo/duckduckgo-help-pages/git/trees/master?recursive=1";
	const baseURL = "https://duckduckgo.com/duckduckgo-help-pages";

	const workArray = JSON.parse(httpRequest(docsURL)).tree.map(
		(/** @type {{ path: string; }} */ entry) => {
			const path = entry.path;
			const [_, subsite] = path.match(/^_docs\/(.*)\.md$/) || [];
			if (!subsite || subsite.startsWith("_")) return {};

			const url = `${baseURL}/${subsite}`;
			let [category, title] = subsite.split("/");
			if (!title) {
				title = category
				category = "";
			}

			return {
				title: prettyString(title),
				subtitle: prettyString(category),
				mods: {
					cmd: { arg: subsite }, // copy entry
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
