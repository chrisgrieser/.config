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

// get the keywords that activate something in Alfred
function getAlfredKeywords() {
	const keywords = app
		.doShellScript("cd .. && grep -r -A1 '<key>keyword' ./**/info.plist | awk 'NR % 3 == 2'")
		.split("\r")
		.reduce((acc, line) => {
			const value = line.split(">")[1].split("<")[0];
			const keywords = [];

			// DOCS ALFRED KEYWORDS https://www.alfredapp.com/help/workflows/advanced/keywords/
			// 1) `{var:alfred_var}`: configurable keywords
			if (value.startsWith("{var:")) {
				const varName = value.split("{var:")[1].split("}")[0];
				const workflowPath = line.split("/info.plist")[0];
				// 1a) user-set keywords
				// (`plutil` will fail, since the value is not saved in prefs.plist)
				try {
					const userKeyword = app.doShellScript(
						`cd .. && plutil -extract "${varName}" raw -o - "${workflowPath}/prefs.plist"`,
					);
					keywords.push(userKeyword);
				} catch (_error) {
					// 1b) keywords where user kept the default value
					const workflowConfig = JSON.parse(
						app.doShellScript(
							`cd .. && plutil -extract "userconfigurationconfig" json -o - "${workflowPath}/info.plist"`,
						),
					);
					const defaultValue = workflowConfig.find(
						(/** @type {{ variable: string; }} */ option) => option.variable === varName,
					).config.default;
					keywords.push(defaultValue);
				}
			}
			// 2) `||`: multiple keyword alternatives
			else if (value.includes("||")) {
				const multiKeyword = value.split("||");
				keywords.push(...multiKeyword);
			}
			// 3) normal keyword
			else {
				keywords.push(value);
			}

			// only keywords with letter as first char are relevant, also only the
			// first word of a keyword matters
			const relevantKeywords = keywords.reduce((acc, keyword) => {
				const firstWord = keyword.split(" ")[0];
				if (firstWord.match(/^[a-z]/)) acc.push(firstWord);
				return acc;
			}, []);

			acc.push(...relevantKeywords);
			return acc;
		}, []);

	// remove pseudo keywords from string
	// (HACK to simplify removing sequence of items from an array, converting
	// it to a string, removing the substring, then back to an array)
	const pseudoKeywords = "c,a,b,e,f,d,h,i,g,l,j,k,o,n,m,q,r,p,u,s,t,v,w,x,z,y";
	const trueKeywords = keywords
		.join(",") // to string
		.split(pseudoKeywords) // remove substring
		.join("")
		.split(","); // back to array
	const uniqueKeywords = [...new Set(trueKeywords)];
	return uniqueKeywords;
}

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
	if (ignoreAlfredKeywords && !isUsingFallbackSearch) {
		const timelogKeywordIgnore = +new Date();
		const queryFirstWord = query.split(" ")[0];
		const alfredKeywords = getAlfredKeywords();
		if (alfredKeywords.includes(queryFirstWord)) return;

		const duration = (+new Date() - timelogKeywordIgnore) / 1000;

		// TODO with more than 50 workflows installed, and 180+ keywords, keyword
		// identification takes about 250ms on my M1 machine. Consider caching?
		console.log("time to identify Alfred keywords:", duration, "s");
		console.log("number of keywords:", alfredKeywords.length);
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
