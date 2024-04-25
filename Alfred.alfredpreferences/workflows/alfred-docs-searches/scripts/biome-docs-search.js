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

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const docsUrl = "https://api.github.com/repos/biomejs/website/git/trees/main?recursive=1";
	const baseUrl = "https://biomejs.dev";
	const docPathRegex = /^src\/content\/docs\/(.*)\.mdx?$/i;

	const workArray = JSON.parse(app.doShellScript(`curl -sL "${docsUrl}"`)).tree.map(
		(/** @type {{ path: string; }} */ entry) => {
			const path = entry.path;

			// GUARD
			const translatedDocs =
				path.includes("/zh-cn/") || path.includes("/ja/") || path.includes("/pt-br/");
			const isDocsSite = docPathRegex.test(path) && !path.endsWith("404.md");
			if (translatedDocs || !isDocsSite) return {};

			const subsite = path.replace(docPathRegex, "$1");
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
				quicklookurl: url,
				uid: subsite,
			};
		},
	);

	return JSON.stringify({
		items: workArray,
		cache: { seconds: 3600 * 24 },
	});
}
