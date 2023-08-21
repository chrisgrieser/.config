#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const alfredMatcher = (/** @type {string} */ str) => str.replace(/[-()_./]/g, " ") + " " + str + " ";

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const workArray = JSON.parse(
		app.doShellScript('curl -s "https://api.github.com/repos/espanso/website/git/trees/main?recursive=1"'),
	)
		.tree.filter(
			(/** @type {{ path: string}} */ file) =>
				/^docs\/.*\.mdx?$/.test(file.path) && !file.path.includes("/_"),
		)
		.map((/** @type {{ path: string; }} */ file) => {
			const site = file.path
				.slice(5) // remove "docs/"
				.replace(/\.mdx?$/, ""); // remove file extension
			const parts = site.split("/");
			const displayTitle = parts.pop().replace(/[_-]/g, " ");
			const parentSite = parts.join("/");
			const url = "https://espanso.org/docs/" + site;

			return {
				title: displayTitle,
				subtitle: parentSite,
				match: alfredMatcher(site),
				arg: url,
				uid: site,
			};
		});

	return JSON.stringify({ items: workArray });
}
