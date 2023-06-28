#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib")
const app = Application.currentApplication()
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @typedef {Object} DdgrJson
 * @property {string} title
 * @property {string} abstract
 * @property {string} url
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const query = $.getenv("query"); // passed from previous script filter
	const maxLength = 100; // length of the Alfred bar
	const resultsToFetch = 9; // only 9 can be displayed in Alfred

	/** @type DdgrJson[] */
	const resultJson = JSON.parse(app.doShellScript(`ddgr --num=${resultsToFetch} --json "${query}"`));

	/** @type AlfredItem[] */
	const searchResults = resultJson.map((item) => {
		const previewText = item.abstract.slice(0, maxLength)
		return {
			title: item.title,
			subtitle: item.url,
			arg: item.url,
			// hold `cmd` to show the url instead of the abstract in the subtitle row
			mods: { cmd: { subtitle: previewText } },
		};
	});

	return JSON.stringify({ items: searchResults });
}
