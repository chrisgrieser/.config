#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
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
	let resultsToFetch = parseInt($.getenv("inline_results_to_fetch"));
	if (resultsToFetch < 1) resultsToFetch = 1;
	else if (resultsToFetch > 25) resultsToFetch = 25;

	/** @type DdgrJson[] */
	let responseJson;
	try {
		// TODO parse directly to leave out ddgr dependency?
		// https://html.duckduckgo.com/html/?q=foobar
		responseJson = JSON.parse(app.doShellScript(`ddgr --num=${resultsToFetch} --json "${query}"`));
	} catch (_error) {
		return JSON.stringify({
			items: [{ title: "🚫 ddgr not found or could not fetch downloads.", valid: false }],
		});
	}

	/** @type AlfredItem[] */
	const searchResults = responseJson.map((item) => {
		const previewText = item.abstract.slice(0, maxLength);
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
