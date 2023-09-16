#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	return str.replace(/[-()_.:#/\\;,[\]]/g, " ");
}

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const baseURL = "https://raw.githubusercontent.com/starship/starship/master/docs/config/README.md";
	const docsURL = "https://starship.rs/config/#";

	const workArray = app
		.doShellScript(`curl -s "${baseURL}"`)
		.split("\r")
		.filter((line) => line.startsWith("## ")) // markdown h2
		.map((heading) => {
			heading = heading.slice(3);
			const anchor = heading.replaceAll(" ", "-").toLowerCase();
			const url = docsURL + anchor;
			return {
				title: heading,
				match: alfredMatcher(heading),
				arg: url,
				uid: heading,
			};
		});

	return JSON.stringify({ items: workArray });
}
