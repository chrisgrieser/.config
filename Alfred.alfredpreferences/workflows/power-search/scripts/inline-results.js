#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
ObjC.import("Foundation");
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
const cacheRecreationThresholdMins = 60;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} filepath */
function getFileAgeMins(filepath) {
	const creationDate = Application("System Events").aliases[filepath].creationDate();
	const cacheAgeMins = (+new Date() - creationDate) / 1000 / 60;
	return cacheAgeMins;
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

// get the Alfred keywords and write them to the cachePath
// PERF Saving keywords in a cache saves ~250ms for me (50+ workflows, 180+ keywords)
/** @param {string} cachePath */
function refreshKeywordsCache(cachePath) {
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

	// HACK remove keywords from this very workflow. Cannot be done based on the
	// foldername, since Alfred assigns a unique ID to local installations.
	// (to simplify removing sequence of items from an array, also uses a HACK,
	// converting namely it to a string, removing the substring, then back to an array)
	const pseudoKeywords = "c,a,b,e,f,d,h,i,g,l,j,k,o,n,m,q,r,p,u,s,t,v,w,x,z,y";
	const trueKeywords = keywords
		.join(",") // to string
		.split(pseudoKeywords) // remove substring
		.join("")
		.split(","); // back to array
	const uniqueKeywords = [...new Set(trueKeywords)];
	console.log("unique keywords:", uniqueKeywords);
	writeToFile(cachePath, JSON.stringify(uniqueKeywords));
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const timelogStart = +new Date();

	const query = argv[0];

	// Guard clause 1: query less than 3 chars or a URL
	if (query.length < 3 || query.match(/^\w+:/)) return;

	// Guard clause 2: first word of query is alfred keyword
	if (ignoreAlfredKeywords && !isUsingFallbackSearch) {
		const cachePath = $.getenv("alfred_workflow_cache") + "/alfred_keywords.json";

		if (!fileExists(cachePath)) {
			refreshKeywordsCache(cachePath);
		} else {
			if (getFileAgeMins(cachePath) > cacheRecreationThresholdMins) refreshKeywordsCache(cachePath);
		}
		const alfredKeywords = JSON.parse(readFile(cachePath));

		const queryFirstWord = query.split(" ")[0];
		if (alfredKeywords.includes(queryFirstWord)) return;
	}

	//───────────────────────────────────────────────────────────────────────────

	// values from previous run
	const oldQuery = $.NSProcessInfo.processInfo.environment.objectForKey("oldQuery").js;
	const oldResults = JSON.parse(
		$.NSProcessInfo.processInfo.environment.objectForKey("oldResults").js || "[]",
	);
	const searchForQuery = {
		title: query,
		uid: query,
		arg: $.getenv("search_site") + encodeURIComponent(query),
	};

	//───────────────────────────────────────────────────────────────────────────

	// USE OLD RESULTS
	// PERF If the user is typing, return early to guarantee the top entry is the currently typed query
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
	// PERF cache new response so that reopening Alfred does not re-fetch results
	const responseCache = $.getenv("alfred_workflow_cache") + "/reponseCache.json";
	let response;
	if (fileExists(responseCache)) {
		response = readFile(responseCache);
	} else {
		// PERF `--noua` disables user agent & fetches faster (~100ms, according to hyperfine)
		// PERF the number of results fetched has basically no effect on the speed
		// (less than 50ms difference between 1 and 25 results), so there is no use
		// in restricting the number of results for performance, (except for 25 being
		// ddgr's maximum)
		const ddgrCommand = `ddgr --noua ${includeUnsafe} --num=${resultsToFetch} --json "${query}"`;
		response = app.doShellScript(ddgrCommand);
		writeToFile(responseCache, response);
	}

	// Icon for saved URLs (multi-select)
	const bufferPath = $.getenv("alfred_workflow_cache") + "/urlsToOpen.json";
	const savedUrls = fileExists(bufferPath) ? readFile(bufferPath).split("\n") : [];

	const newResults = JSON.parse(response).map(
		(/** @type {{ title: string; url: string; abstract: string; }} */ item) => {
			const savedIcon = savedUrls.includes(item.url) ? "🔵 " : "";
			return {
				title: savedIcon + item.title,
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
