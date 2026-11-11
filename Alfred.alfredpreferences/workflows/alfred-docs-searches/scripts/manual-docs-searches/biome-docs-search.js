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
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const docsUrl = "https://api.github.com/repos/biomejs/website/git/trees/main?recursive=1";
	const baseUrl = "https://biomejs.dev";

	// https://github.com/biomejs/website/tree/main/src/content/docs/en
	const docPathRegex = /^src\/content\/docs\/en\/(.*)\.mdx?$/;

	const response = JSON.parse(httpRequest(docsUrl));
	if (!response) return JSON.stringify({ items: [{ title: "Could not load.", valid: false }] });

	const workArray = response.tree.flatMap((/** @type {{ path: string; }} */ entry) => {
		const path = entry.path;
		const [_, subsite] = path.match(docPathRegex) || [];

		if (!subsite) return [];
		if (path.endsWith("404.md")) return [];

		const parts = subsite.split("/");

		let title = parts.pop() || "??";
		const allLangs = ["javascript", "typescript", "html", "json", "css", "markdown", "graphql"];
		let lang = "";
		if (allLangs.includes(title)) {
			lang = title
				.replaceAll("javascript", "JavaScript")
				.replaceAll("typescript", "TypeScript")
				.replaceAll("json", "JSON")
				.replaceAll("css", "CSS")
				.replaceAll("html", "HTML")
			title = parts.pop() || "??";
		}

		let category = parts.join("/") + (lang ? ` (${lang})` : "");
		let url = `${baseUrl}/${subsite}`;

		if (subsite.endsWith("index")) {
			title = category;
			category = "";
			url = `${baseUrl}/${subsite.slice(0, -5)}`;
		}

		title = title
			.replace(/-\w/g, (match) => match.slice(-1).toUpperCase()) // camelCase to conform to rule-casing the user expects
			.replaceAll("-", " ");
		title = title.charAt(0).toUpperCase() + title.slice(1); // capitalize

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
