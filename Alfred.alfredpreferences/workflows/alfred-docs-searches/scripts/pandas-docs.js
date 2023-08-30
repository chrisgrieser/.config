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

/** @param {string} str */
function capitalize(str) {
	return str.charAt(0).toUpperCase() + str.slice(1);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const docsUrl = "https://api.github.com/repos/pandas-dev/pandas/git/trees/main?recursive=1";
	const baseUrl = "https://pandas.pydata.org/docs";

	const idRegex = new RegExp("doc/source/(.*)\\.rst$");

	const workArray = JSON.parse(app.doShellScript(`curl -s "${docsUrl}"`))
		.tree.filter((/** @type {{ path: string; }} */ file) => {
			return (
				idRegex.test(file.path) &&
				!file.path.includes("what" + "snew") &&
				!file.path.includes("comparison/includes/") // not real files, automated integration into comparisons
			);
		})
		.map((/** @type {{ path: string }} */ entry) => {
			const subsite = entry.path.replace(idRegex, "$1");
			const parts = subsite.split("/");

			const displayTitle = parts.pop().replace(/_/g, " ");
			const category = parts.join(" – ").replace(/_/g, " ");
			const url = `${baseUrl}/${subsite}.html`;

			return {
				title: capitalize(displayTitle),
				subtitle: capitalize(category),
				match: alfredMatcher(subsite),
				arg: url,
				uid: subsite,
			};
		});

	return JSON.stringify({ items: workArray });
}
