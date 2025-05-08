#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [camelCaseSeparated, str].join(" ") + " ";
}

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
	const docsUrl = "https://api.github.com/repos/biomejs/website/git/trees/main?recursive=1";
	const baseUrl = "https://biomejs.dev";

	// `\w{3,}` excludes translations of the docs, which are in folders like
	// `/ja/` or `/zh-CN/` https://github.com/biomejs/website/tree/main/src/content/docs
	const docPathRegex = /^src\/content\/docs\/(\w{3,}.*)\.mdx?$/;

	const response = JSON.parse(httpRequest(docsUrl));
	if (!response) return JSON.stringify({ items: [{ title: "Could not load.", valid: false }] });

	const workArray = response.tree.map((/** @type {{ path: string; }} */ entry) => {
		const path = entry.path;
		const [_, subsite] = path.match(docPathRegex) || [];

		if (!subsite) return {};
		if (path.endsWith("404.md")) return {};

		const parts = subsite.split("/");
		let title = parts.pop() || "??";
		let category = parts.join("/");
		let url = `${baseUrl}/${subsite}`;

		if (subsite.endsWith("index")) {
			title = category;
			category = "";
			url = `${baseUrl}/${subsite.slice(0, -5)}`;
		}

		if (category.endsWith("rules")) {
			// camelCase to conform to rule-casing the user expects
			title = title.replace(/-\w/g, (match) => match.slice(-1).toUpperCase());
		} else {
			// capitalize
			title = title.replaceAll("-", " ");
			title = title.charAt(0).toUpperCase() + title.slice(1); // capitalize
		}

		return {
			title: title,
			subtitle: category,
			match: alfredMatcher(title),
			arg: url,
			mods: {
				cmd: { arg: title }, // copy entry
			},
			quicklookurl: url,
			uid: title,
		};
	});

	return JSON.stringify({
		items: workArray,
		cache: {
			seconds: 3600 * 24 * 7, // 7 days
			loosereload: true,
		},
	});
}
