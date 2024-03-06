#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const docsUrl = "https://api.github.com/repos/biomejs/biome/git/trees/main?recursive=1";
	const baseUrl = "https://biomejs.dev";
	const docPathRegex = /^website\/src\/content\/docs\/(.*)\.mdx?$/i;

	const workArray = JSON.parse(app.doShellScript(`curl -sL "${docsUrl}"`)).tree.map(
		(/** @type {{ path: string; }} */ entry) => {
			// GUARD
			const translatedDocs = entry.path.includes("/zh-cn/") || entry.path.includes("/ja/");
			const isDocsSite = docPathRegex.test(entry.path) && !entry.path.endsWith("404.md");
			if (translatedDocs || !isDocsSite) return {};

			const subsite = entry.path.replace(docPathRegex, "$1");
			const parts = subsite.split("/");
			let displayTitle = parts.pop();
			let category = parts.join("/");
			let url = `${baseUrl}/${subsite}`;

			if (subsite.endsWith("index")) {
				displayTitle = category;
				category = "";
				url = `${baseUrl}/${subsite.slice(0, -5)}`;
			}

			// prettier display
			if (!category.endsWith("rules")) {
				displayTitle = displayTitle.replaceAll("-", " ");
				displayTitle = displayTitle.charAt(0).toUpperCase() + displayTitle.slice(1); // capitalize
			}

			return {
				title: displayTitle,
				subtitle: category,
				match: alfredMatcher(subsite),
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
