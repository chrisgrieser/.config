#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const minQueryLength = parseInt($.getenv("min_query_length")) || 5;
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
function run(argv) {
	// Check values from previous runs this session
	const query = argv[0];
	const oldQuery = $.NSProcessInfo.processInfo.environment.objectForKey("oldQuery").js;
	const oldResults = JSON.parse(
		$.NSProcessInfo.processInfo.environment.objectForKey("oldResults").js || "[]",
	);

	// Guard clauses
	if (query.length < minQueryLength) return;

	const alfredKeywords = app
		.doShellScript("cd .. && grep -r -A1 '<key>keyword' ./**/info.plist | awk 'NR % 3 == 2'")
		.split("\r")
		.reduce((acc, line) => {
			if (line.includes("{var:")) return acc; // TODO implement {var:alfred_var}
			const keyword = line.split("<")[1].split(">")[0];
			if (keyword.includes("||")) // DOCS https://www.alfredapp.com/help/workflows/advanced/keywords/
			acc.push(keyword);
			return acc;
		}, [])

	//───────────────────────────────────────────────────────────────────────────

	const searchForQuery = {
		title: query,
		uid: query,
		arg: $.getenv("search_site") + query,
		mods: {
			cmd: {
				arg: "open_URLs",
				subtitle: "⌘: Open all saved results",
			},
		},
	};

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
	// `--noua` disables user agent & fetches faster (~10% faster according to hyperfine)
	// INFO the number of results fetched does basically no effect on the speed
	// (less than 50ms difference between 1 and 25 results), so there is no use
	// in restricting the number of results for performance (25 is ddgr's maximum)
	const ddgrCommand = `ddgr --noua ${includeUnsafe} --num=${resultsToFetch} --json "${query}"`;
	const responseJson = JSON.parse(app.doShellScript(ddgrCommand));
	const newResults = responseJson.map((/** @type {DdgrSearchResult} */ item) => {
		return {
			title: item.title,
			subtitle: item.url,
			uid: item.url,
			arg: item.url,
			icon: { path: "duckduckgo.png" },
			mods: {
				shift: { subtitle: item.abstract },
			},
		};
	});

	return JSON.stringify({
		skipknowledge: true,
		variables: { oldResults: JSON.stringify(newResults), oldQuery: query },
		items: [searchForQuery].concat(newResults),
	});
}
