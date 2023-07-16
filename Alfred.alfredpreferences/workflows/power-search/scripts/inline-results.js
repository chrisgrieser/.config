#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const minQueryLength = parseInt($.getenv("min_query_length")) || 5;
const noSuggestionRegex = new RegExp($.getenv("no_suggestion_regex"));
const includeUnsafe = $.getenv("include_unsafe") === "1" ? "--unsafe" : "";

let resultsToFetch = parseInt($.getenv("inline_results_to_fetch"));
if (resultsToFetch < 1) resultsToFetch = 1;
else if (resultsToFetch > 25) resultsToFetch = 25; // maximum supported by ddgr

//──────────────────────────────────────────────────────────────────────────────

/** @typedef {Object} DdgrSearchResult
 * @property {string} title
 * @property {string} abstract
 * @property {string} url
 */

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// Check values from previous runs this session
	const query = argv[0];
	const oldQuery = $.NSProcessInfo.processInfo.environment.objectForKey("oldQuery").js;
	const oldResults = JSON.parse(
		$.NSProcessInfo.processInfo.environment.objectForKey("oldResults").js || "[]",
	);

	//───────────────────────────────────────────────────────────────────────────

	// FALLBACK RESULTS
	const arg = query.includes(".") ? "https://" + query : $.getenv("search_site") + query;
	const searchForQuery = { title: query, uid: query, arg: arg };
	const showFallbackOnly = query.length < minQueryLength;
	const showNothing = noSuggestionRegex.test(query) || query.length < 3;

	if (showNothing) return;
	if (showFallbackOnly) {
		return JSON.stringify({
			rerun: 0.1,
			skipknowledge: true,
			variables: { oldResults: JSON.stringify(oldResults), oldQuery: query },
			items: [searchForQuery],
		});
	}

	//───────────────────────────────────────────────────────────────────────────

	// USE OLD RESULTS
	// If the user is typing, return early to guarantee the top entry is the currently typed query
	// If we waited for the API, a fast typer would search for an incomplete query
	if (query !== oldQuery) {
		return JSON.stringify({
			rerun: 0.1,
			skipknowledge: true,
			variables: { oldResults: JSON.stringify(oldResults), oldQuery: query },
			items: [searchForQuery].concat(oldResults),
		});
	}

	// REQUEST NEW RESULTS
	// --noua: disables user agent and fetches results faster
	const ddgrCommand = `ddgr --noua ${includeUnsafe} --num=${resultsToFetch} --json "${query}"`;
	const responseJson = JSON.parse(app.doShellScript(ddgrCommand));
	const newResults = responseJson.map((/** @type {DdgrSearchResult} */ item) => {
		const previewText = item.abstract.slice(0, 80); // smaller amount of data passed between queries
		return {
			title: item.title,
			subtitle: item.url,
			uid: item.url,
			arg: item.url,
			icon: { path: "duckduckgo.png" },
			mods: {
				cmd: { subtitle: previewText },
			},
		};
	});

	return JSON.stringify({
		skipknowledge: true,
		variables: { oldResults: JSON.stringify(newResults), oldQuery: query },
		items: [searchForQuery].concat(newResults),
	});
}
