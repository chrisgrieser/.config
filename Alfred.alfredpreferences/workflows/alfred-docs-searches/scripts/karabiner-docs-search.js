#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function kebabToTitleCase(str) {
	return str
		.replaceAll("-", " ")
		.replace(/\w+/g, (word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase());
}

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
			const site = file.path.replace(docsRegex, "$1");
			const parts = site.split("/");
			const subsite = kebabToTitleCase(parts.pop());
			const parentSite = kebabToTitleCase(parts.join("  ·  "));
			const url = `${baseUrl}/${site}/`;
			return {
				title: subsite,
				subtitle: parentSite,
				match: `${subsite} ${parentSite}`,
				arg: url,
				uid: site,
			};
		});

	return JSON.stringify({
		items: workArray,
		cache: { seconds: 3600 * 24 },
	});
}
