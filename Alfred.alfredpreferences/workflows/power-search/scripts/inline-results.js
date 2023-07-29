#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const includeUnsafe = $.getenv("include_unsafe") === "1" ? "--unsafe" : "";
let resultsToFetch = parseInt($.getenv("inline_results_to_fetch")) || 5;
if (resultsToFetch < 1) resultsToFetch = 1;
else if (resultsToFetch > 25) resultsToFetch = 25; // maximum supported by `ddgr`
const ignoreAlfredKeywordsEnabled = $.getenv("ignore_alfred_keywords") === "1";

const multiSelectIcon = "🔳";

//──────────────────────────────────────────────────────────────────────────────

/** considers the possibility of the cache not existing, as well as the
 * possibility of the user having set a custom location for their preferences
 * @param {string} cachePath
 */
function keywordCacheIsOutdated(cachePath) {
	const getFileObj = (/** @type {string} */ path) => Application("System Events").aliases[path];
	const cacheObj = getFileObj(cachePath);
	if (!cacheObj.exists()) return true;
	const alfredConfigObj = getFileObj($.getenv("alfred_preferences"));
	const isOutdated = alfredConfigObj.modificationDate() > cacheObj.creationDate();
	return isOutdated;
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

//──────────────────────────────────────────────────────────────────────────────

// get the Alfred keywords and write them to the cachePath
// PERF Saving keywords in a cache saves ~250ms for me (50+ workflows, 180+ keywords)
/** @param {string} cachePath */
function refreshKeywordCache(cachePath) {
	const keywords = app
		.doShellScript("cd .. && grep -r -A1 '<key>keyword' ./**/info.plist | awk 'NR % 3 == 2'")
		.split("\r")
		.reduce((acc, line) => {
			const value = line.split(">")[1].split("<")[0];
			const keywords = [];

			// DOCS ALFRED KEYWORDS https://www.alfredapp.com/help/workflows/advanced/keywords/
			// CASE 1: `{var:alfred_var}` -> configurable keywords
			if (value.startsWith("{var:")) {
				const varName = value.split("{var:")[1].split("}")[0];
				const workflowPath = line.split("/info.plist")[0];
				// CASE 1a) user-set keywords
				// (`plutil` will fail, since the value is not saved in prefs.plist)
				try {
					const userKeyword = app.doShellScript(
						`plutil -extract "${varName}" raw -o - "../${workflowPath}/prefs.plist"`,
					);
					keywords.push(userKeyword);
				} catch (_error) {
					// CASE 1b: keywords where user kept the default value
					const workflowConfig = JSON.parse(
						app.doShellScript(
							`plutil -extract "userconfigurationconfig" json -o - "../${workflowPath}/info.plist"`,
						),
					);
					const defaultValue = workflowConfig.find(
						(/** @type {{ variable: string; }} */ option) => option.variable === varName,
					).config.default;
					keywords.push(defaultValue);
				}
			}
			// CASE 2: `||` -> multiple keyword alternatives
			else if (value.includes("||")) {
				const multiKeyword = value.split("||");
				keywords.push(...multiKeyword);
			}
			// CASE 3: regular keyword
			else {
				keywords.push(value);
			}

			// - also only the first word of a keyword matters
			// - only keywords with letter as first char are relevant
			const relevantKeywords = keywords.reduce((acc, keyword) => {
				const firstWord = keyword.split(" ")[0];
				if (firstWord.match(/^[a-z]/)) acc.push(firstWord);
				return acc;
			}, []);

			acc.push(...relevantKeywords);
			return acc;
		}, []);

	// HACK remove keywords from this very workflow. Cannot be done based on the
	// foldername, since Alfred assigns a unique ID to local installations. The
	// specific sequence of items is relevant, it is dependent on the occurrence
	// of script filters in Alfred's "workflow canvas" and will change if script
	// filter there re-arranged.
	// (HACK to simplify removing sequence of items from an array, we convert it
	// to a string, remove the substring, then convert it back)
	const pseudoKeywords = "c,a,b,e,f,d,h,i,g,l,j,k,o,n,m,q,r,p,u,s,t,v,w,x,z,y";
	const trueKeywords = keywords
		.join(",") // to string
		.split(pseudoKeywords) // remove substring
		.join("")
		.split(","); // back to array
	const uniqueKeywords = [...new Set(trueKeywords)];
	console.log(`Rebuilt cache: ${uniqueKeywords} keywords.`);
	writeToFile(cachePath, JSON.stringify(uniqueKeywords));
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const timelogStart = +new Date();

	const mode = $.NSProcessInfo.processInfo.environment.objectForKey("mode").js || "default";
	const query = argv[0];

	// GUARD CLAUSE 1:
	// - query < 3 chars
	// - query == URL
	if (query.length < 3 || query.match(/^\w+:/)) return;

	// GUARD CLAUSE 2: first word of query is Alfred keyword
	// (guard clause is ignored when doing fallback search or multi-select,
	// since in that case we know we do not need to ignore anything.)
	if (ignoreAlfredKeywordsEnabled && mode !== "fallback" && mode !== "multi-select") {
		const keywordCachePath = $.getenv("alfred_workflow_cache") + "/alfred_keywords.json";
		if (keywordCacheIsOutdated(keywordCachePath)) refreshKeywordCache(keywordCachePath);
		const alfredKeywords = JSON.parse(readFile(keywordCachePath));
		const queryFirstWord = query.split(" ")[0];
		if (alfredKeywords.includes(queryFirstWord)) {
			console.log("Ignored due to Alfred keyword: " + queryFirstWord);
			return;
		}
	}

	// GUARD CLAUSE 3: use old results
	// get values from previous run
	const oldQuery = $.NSProcessInfo.processInfo.environment.objectForKey("oldQuery").js;
	const oldResults = $.NSProcessInfo.processInfo.environment.objectForKey("oldResults").js || "[]";
	const searchForQuery = {
		title: `"${query}"`,
		uid: query,
		arg: $.getenv("search_site") + encodeURIComponent(query),
	};

	// PERF & HACK If the user is typing, return early to guarantee the top entry
	// is the currently typed query. If we waited for `ddgr`, a fast typer would
	// search for an incomplete query
	if (query !== oldQuery) {
		searchForQuery.subtitle = "Loading Inline Results…";
		return JSON.stringify({
			rerun: 0.1,
			skipknowledge: true,
			variables: { oldResults: oldResults, oldQuery: query },
			items: [searchForQuery].concat(JSON.parse(oldResults)),
		});
	}

	//───────────────────────────────────────────────────────────────────────────
	// MAIN: request NEW results

	// PERF cache `ddgr` response so that re-opening Alfred or using multi-select
	// does not re-fetch results
	const responseCachePath = $.getenv("alfred_workflow_cache") + "/reponseCache.json";
	const responseCache = JSON.parse(readFile(responseCachePath) || "{}");
	let results = [];
	if (responseCache.query === query) {
		results = responseCache.results;
	} else {
		// PERF `--noua` disables user agent & fetches faster (~100ms according to hyperfine)
		// PERF the number of results fetched has basically no effect on the speed
		// (less than 50ms difference between 1 and 25 results), so there is no use
		// in restricting the number of results for performance. (Rxcept for 25 being
		// ddgr's maximum)
		const ddgrCommand = `ddgr --noua ${includeUnsafe} --num=${resultsToFetch} --json "${query}"`;
		const response = {};
		response.results = JSON.parse(app.doShellScript(ddgrCommand));
		response.query = query;
		writeToFile(responseCachePath, JSON.stringify(response));
		results = response.results;
	}

	// determine icon for multi-select from saved URLs
	const multiSelectBufferPath = $.getenv("alfred_workflow_cache") + "/multiSelectBuffer.txt";
	const multiSelectUrls = readFile(multiSelectBufferPath).split("\n") || [];

	const newResults = results.map((/** @type {{ title: string; url: string; abstract: string; }} */ item) => {
		const isSelected = multiSelectUrls.includes(item.url);
		const icon = isSelected ? multiSelectIcon + " " : "";
		return {
			title: icon + item.title,
			subtitle: item.url,
			uid: item.url,
			arg: isSelected ? "" : item.url, // if URL already selected, no need to pass it
			icon: { path: "icons/1.png" },
			mods: {
				shift: { subtitle: item.abstract },
				cmd: {
					arg: item.url, // has to be set, since main arg can be ""
					variables: { mode: "multi-select" },
					subtitle: isSelected ? "⌘: Deselect URL" : "⌘: Select URL",
				},
			},
		};
	});

	// if searchForQuery has been multi-selected, adapt its result as well
	if (multiSelectUrls.includes(searchForQuery.arg)) {
		searchForQuery.title = multiSelectIcon + " " + searchForQuery.title;
		searchForQuery.mods = {
			cmd: {
				arg: searchForQuery.arg, // has to be set, since main arg can be ""
				variables: { mode: "multi-select" },
				subtitle: "⌘: Deselect URL",
			},
		};
		searchForQuery.arg = ""; // if URL already selected, no need to pass it
	}

	// Pass to Alfred
	const alfredInput = JSON.stringify({
		rerun: 0.2, // HACK has to permanently rerun to pick up changes from multi-select
		skipknowledge: true, // so Alfred does not change result order for multi-select
		variables: { oldResults: JSON.stringify(newResults), oldQuery: query },
		items: [searchForQuery].concat(newResults),
	});

	const durationTotalSecs = (+new Date() - timelogStart) / 1000;
	let log = `${durationTotalSecs}s`;
	if (mode !== "default") log += ` (${mode})`;
	console.log(log);

	return alfredInput;
}
