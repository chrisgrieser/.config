#!/usr/bin/env osascript -l JavaScript

// CONFIG
ObjC.import("stdlib");
const maxResults = parseInt($.getenv("max_suggestions")) || 2;
const minQueryLength = parseInt($.getenv("min_query_length")) || 5;
const noSuggestionRegex = new RegExp($.getenv("no_suggestion_regex"));

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} itemNames */
function makeItems(itemNames) {
	return itemNames.map((/** @type {string} */ name) => {
		// turn word into url
		let url;
		if (name?.startsWith("http")) url = name;
		else if (name?.includes(".")) url = "https://" + name;
		else $.getenv("search_site") + name;

		return {
			uid: name,
			title: name,
			arg: url,
			// no argument for next script filter
			mods: {
				shift: {
					arg: "",
					variables: { query: name },
				},
			},
		};
	});
}

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

//──────────────────────────────────────────────────────────────────────────────

// Build items
/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// Check values from previous runs this session
	const oldArg = $.NSProcessInfo.processInfo.environment.objectForKey("oldArg").js;
	const oldResults = $.NSProcessInfo.processInfo.environment.objectForKey("oldResults").js;
	const query = argv[0];
	console.log("oldArg:", oldArg);
	console.log("query:", query);

	// regex ignore & ignore queries shorter than 3 characters
	if (noSuggestionRegex.test(query) || query.length < 3) return;

	// make no request below the minimum length, but show the typed query as
	// fallback search
	if (query.length < minQueryLength) {
		return JSON.stringify({
			rerun: 0.1,
			skipknowledge: true,
			variables: { oldResults: oldResults, oldArg: query },
			items: makeItems([query]),
		});
	}

	// If the user is typing, return early to guarantee the top entry is the currently typed query
	// If we waited for the API, a fast typer would search for an incomplete query
	if (query !== oldArg) {
		return JSON.stringify({
			rerun: 0.1,
			skipknowledge: true,
			variables: { oldResults: oldResults, oldArg: query },
			items: makeItems(argv.concat(oldResults?.split("\n").filter((/** @type {string} */ line) => line))),
		});
	}

	// Make the API request
	const queryURL = $.getenv("suggestion_source") + encodeURIComponent(query);
	const response = JSON.parse(httpRequest(queryURL));
	const usingGoogle = $.getenv("suggestion_source").includes("google");
	const newResults = (
		usingGoogle ? response[1] : response.map((/** @type {{ phrase: string; }} */ t) => t.phrase)
	)
		.filter((/** @type {string} */ result) => result !== query)
		.slice(0, maxResults);

	// Return final JSON
	return JSON.stringify({
		skipknowledge: true,
		variables: { oldResults: newResults.join("\n"), oldArg: query },
		items: makeItems(argv.concat(newResults)),
	});
}
