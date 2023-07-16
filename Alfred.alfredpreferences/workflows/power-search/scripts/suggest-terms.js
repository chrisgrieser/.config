#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const minQueryLength = parseInt($.getenv("min_query_length")) || 5;
const noSuggestionRegex = new RegExp($.getenv("no_suggestion_regex"));

let resultsToFetch = parseInt($.getenv("inline_results_to_fetch"));
if (resultsToFetch < 1) resultsToFetch = 1;
else if (resultsToFetch > 25) resultsToFetch = 25;

//──────────────────────────────────────────────────────────────────────────────

// Build items
/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// Check values from previous runs this session
	const oldArg = $.NSProcessInfo.processInfo.environment.objectForKey("oldArg").js;
	const oldResults = $.NSProcessInfo.processInfo.environment.objectForKey("oldResults").js;
	const query = argv[0];

	// regex ignore & ignore queries shorter than 3 characters
	if (noSuggestionRegex.test(query) || query.length < 3) return;

	const searchForQuery = {
		title: query,
		uid: query,
		arg: query,
	};

	// make no request below the minimum length, but show the typed query as
	// fallback search
	if (query.length < minQueryLength) {
		return JSON.stringify({
			rerun: 0.1,
			skipknowledge: true,
			variables: { oldResults: oldResults, oldArg: query },
			items: [searchForQuery],
		});
	}

	// If the user is typing, return early to guarantee the top entry is the currently typed query
	// If we waited for the API, a fast typer would search for an incomplete query
	if (query !== oldArg) {
		return JSON.stringify({
			rerun: 0.1,
			skipknowledge: true,
			variables: { oldResults: oldResults, oldArg: query },
			items: [searchForQuery].concat(oldResults),
		});
	}

	//───────────────────────────────────────────────────────────────────────────

	const responseJson = JSON.parse(app.doShellScript(`ddgr --num=${resultsToFetch} --json "${query}"`));

	/** @type AlfredItem[] */
	const inlineResults = responseJson.map((item) => {
		return {
			title: item.title,
			subtitle: item.url,
			arg: item.url,
		};
	});

	return JSON.stringify({
		rerun: 0.1,
		skipknowledge: true,
		variables: { oldResults: inlineResults, oldArg: query },
		items: inlineResults,
	});
}
