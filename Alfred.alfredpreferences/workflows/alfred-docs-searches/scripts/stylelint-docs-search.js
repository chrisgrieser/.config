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

	const githubApi = "https://api.github.com/repos/stylelint/stylelint/git/trees/main?recursive=1";
	const baseURL = "https://stylelint.io/user-guide/rules";
	const docsPathRegex = /^lib\/rules\/(.*)\/README\.md$/i;

	const rulesArray = JSON.parse(app.doShellScript(`curl -s "${githubApi}"`))
		.tree.filter((/** @type {{ path: string; }} */ file) => docsPathRegex.test(file.path))
		.map((/** @type {{ path: string; }} */ entry) => {
			const subsite = entry.path.replace(docsPathRegex, "$1");
			const category = "rules"
			const url = `${baseURL}/${subsite}`;

			return {
				title: subsite,
				subtitle: category,
				match: alfredMatcher(subsite),
				arg: url,
				uid: subsite,
			};
		});

	return JSON.stringify({ items: rulesArray });
}
