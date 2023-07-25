#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// CONFIG
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
	const timelogStart = +new Date();

	// Query + values from previous run
	const query = argv[0];
	const oldQuery = $.NSProcessInfo.processInfo.environment.objectForKey("oldQuery").js;
	const oldResults = JSON.parse(
		$.NSProcessInfo.processInfo.environment.objectForKey("oldResults").js || "[]",
	);
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

	//───────────────────────────────────────────────────────────────────────────

	// Guard clause 1: query less than 3 chars
	if (query.length < 3) return;

	// Guard clause 2: first word of query is alfred keyword
	// INFO no need for caching, since this only seems to take ~90ms with > 50
	// workflows installed
	const queryFirstWord = query.match(/^\S+/)[0];
	const alfredKeywords = app
		.doShellScript("cd .. && grep -r -A1 '<key>keyword' ./**/info.plist | awk 'NR % 3 == 2'")
		.split("\r")
		.reduce((acc, line) => {
			const value = line.split(">")[1].split("<")[0];

			// `||` delimites keyword alternatives https://www.alfredapp.com/help/workflows/advanced/keywords/
			// only letter keywords and > 2 chars relevant
			// TODO implement {var:alfred_var}
			const keywords = (value.includes("||") ? value.split("||") : [value]).filter((kw) =>
				kw.match(/^[a-z]../),
			);
			acc.push(...keywords);
			return acc;
		}, []);
	if (alfredKeywords.includes(queryFirstWord)) return;

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

	if ($.getenv("alfred_debug") === "1") {
		const durationTotal = (+new Date() - timelogStart) / 1000;
		console.log("total: ", durationTotal, "s");
	}

	return JSON.stringify({
		skipknowledge: true,
		variables: { oldResults: JSON.stringify(newResults), oldQuery: query },
		items: [searchForQuery].concat(newResults),
	});
}
