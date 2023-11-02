#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// @ts-ignore
const alfredMatcher = (/** @type {string} */ str) => str.replace(/[-()_./]/g, " ") + " " + str + " ";

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const gitHubURL = "https://api.github.com/repos/felixkratz/SketchyBar/git/trees/documentation?recursive=1";
	const workArray = JSON.parse(app.doShellScript(`curl -s "${gitHubURL}"`)).tree
		.filter( (/** @type {{ path: string; }} */ file) => file.path.startsWith("docs/") && file.path.endsWith(".md"))
		.map((/** @type {{ path: string }} */ file) => {
			const site = file.path.slice(5, -3); // remove "docs/" and ".md"
			const parts = site.split("/");
			let subsite = parts.pop();
			subsite = subsite.charAt(0).toUpperCase() + subsite.slice(1); // capitalize
			const parentSite = parts.join("/");
			const url = "https://felixkratz.github.io/SketchyBar/" + site;
			return {
				title: subsite,
				match: alfredMatcher(site),
				subtitle: parentSite,
				arg: url,
				uid: site,
			};
		});

	return JSON.stringify({ items: workArray });
}
