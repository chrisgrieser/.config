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

const isUsingFallbackSearch = Boolean($.NSProcessInfo.processInfo.environment.objectForKey("no_ignore").js);
const ignoreAlfredKeywords = $.getenv("ignore_alfred_keywords") === "1";

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	console.log(""); // newline
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
	// INFO no need for caching, since this only seems to take ~80ms with more
	// than 50 workflows installed
	if (ignoreAlfredKeywords && !isUsingFallbackSearch) {
		const timelogKeywordIgnore = +new Date();
		const queryFirstWord = query.match(/^\S+/)[0];
		const alfredKeywords = app
			.doShellScript("cd .. && grep -r -A1 '<key>keyword' ./**/info.plist | awk 'NR % 3 == 2'")
			.split("\r")
			.reduce((acc, line) => {
				const value = line.split(">")[1].split("<")[0];

				// `||` delimites keyword alternatives –– DOCS https://www.alfredapp.com/help/workflows/advanced/keywords/
				// only letter keywords relevant
				// TODO implement {var:alfred_var}
				const keywords = (value.includes("||") ? value.split("||") : [value]).filter((kw) =>
					kw.match(/^[a-z]/),
				);
				acc.push(...keywords);
				return acc;
			}, []);

		// remove pseudo keywords from string
		// (HACK to simplify removing sequence of items from an array, converting
		// it to a string, removing the substring, then back to an array)
		const pseudoKeywords = "c,a,b,e,f,d,h,i,g,l,j,k,o,n,m,q,r,p,u,s,t,v,w,x,z,y";
		const trueKeywords = alfredKeywords
			.join(",") // to string
			.split(pseudoKeywords) // remove substring
			.join("")
			.split(","); // back to array
		const uniqueKeywords = [...new Set(trueKeywords)];

		const duration = (+new Date() - timelogKeywordIgnore) / 1000;
		console.log("time to identify Alfred keywords:", duration, "s");
		console.log("number of keywords:", uniqueKeywords.length);
		console.log("---");
		console.log("queryFirstWord:", queryFirstWord);
		console.log("keywords:", uniqueKeywords);
		if (uniqueKeywords.includes(queryFirstWord)) return;
	}

	//───────────────────────────────────────────────────────────────────────────

	// USE OLD RESULTS
	// If the user is typing, return early to guarantee the top entry is the currently typed query
	// If we waited for the API, a fast typer would search for an incomplete query
	if (query !== oldQuery) {
		searchForQuery.subtitle = "Loading Inline Results…";
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
	const newResults = responseJson.map(
		(/** @type {{ title: string; url: string; abstract: string; }} */ item) => {
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
		},
	);

	// Measuring execution time
	const durationTotal = (+new Date() - timelogStart) / 1000;
	console.log("total:", durationTotal, "s");

	return JSON.stringify({
		skipknowledge: true,
		variables: { oldResults: JSON.stringify(newResults), oldQuery: query },
		items: [searchForQuery].concat(newResults),
	});
}
