#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const docsURL = "https://api.github.com/repos/eslint/eslint/git/trees/main?recursive=1";
	const baseURL = "https://eslint.org/docs/latest";
	const docPathRegex = /^docs\/src\/(?:rules|use)\/(.*)\.md$/i;

	const workArray = JSON.parse(app.doShellScript(`curl -s "${docsURL}"`))
		.tree.filter((/** @type {{ path: string; }} */ file) => docPathRegex.test(file.path))
		.map((/** @type {{ path: string; }} */ entry) => {
			const subsite = entry.path.slice(9, -3);
			const parts = subsite.split("/");
			const displayTitle = parts.pop();
			const category = parts.join("/");
			const url = `${baseURL}/${subsite}`;

			return {
				title: displayTitle,
				subtitle: category,
				match: alfredMatcher(subsite),
				arg: url,
				uid: subsite,
			};
		});

	return JSON.stringify({ items: workArray });
}
