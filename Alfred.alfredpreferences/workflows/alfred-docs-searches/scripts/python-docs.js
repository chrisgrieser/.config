#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const pythonVersion = $.getenv("python_version");
	const docsURL = "https://api.github.com/repos/python/cpython/git/trees/main?recursive=1";
	const baseURL = `https://docs.python.org/${pythonVersion}`;

	const workArray = JSON.parse(app.doShellScript(`curl -s "${docsURL}"`))
		.tree.filter((/** @type {{ path: string; }} */ file) => /^Doc\/.*\.rst$/.test(file.path))
		.map((/** @type {{ path: string }} */ entry) => {
			const subsite = entry.path.slice(4, -4);
			const category = subsite.split("/")[0];
			const displayTitle = subsite.split("/")[1];
			const url = `${baseURL}/${subsite}.html`;

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
