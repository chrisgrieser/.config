#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const alfredMatcher = (/** @type {string} */ str) => str.replace(/[-()_./]/g, " ") + " " + str + " ";

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const githubApi =
		"https://api.github.com/repos/pqrs-org/gh-pages-karabiner-elements.pqrs.org/git/trees/main?recursive=1";
	const baseUrl = "https://karabiner-elements.pqrs.org/docs";

	const docsRegex = /^docs\/docs\/(.*)\/index\.html$/;

	const workArray = JSON.parse(app.doShellScript(`curl -s "${githubApi}"`))
		.tree.filter((/** @type {{ path: string; }} */ file) => docsRegex.test(file.path))
		.map((/** @type {{ path: string }} */ file) => {
			const site = file.path.slice(15, -11); // remove "docs/docs/json/" and "/index.html"
			const parts = site.split("/");
			const subsite = parts.pop();
			const parentSite = parts.join("/");
			const url = `${baseUrl}/${site}/`;
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
