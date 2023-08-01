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

/** searches for any `.plist` more recently modified than the cache to determine
 * if the cache is outdated. Cannot use the workflow folder's mdate, since it
 * is too far up, and macOS does only changes the mdate of enclosing folders,
 * but not of their parents.
 * - Considers the possibility of the cache not existing
 * - Considers the user potentially having set a custom preferences location, by
 *   simply searching for the `.plist` files relative to this workflow's folder.
 * @param {string} cachePath
 */
function keywordCacheIsOutdated(cachePath) {
	const cacheObj = Application("System Events").aliases[cachePath];
	if (!cacheObj.exists()) return true;
	const cacheAgeMins = ((+new Date() - cacheObj.creationDate()) / 1000 / 60).toFixed(0);
	const workflowConfigChanges = app.doShellScript(
		`find .. -depth 2 -name "*.plist" -mtime -${cacheAgeMins}m`,
	);
	const webSearchConfigChanges = app.doShellScript(
		`find ../../preferences/features/websearch -name "prefs.plist" -mtime -${cacheAgeMins}m`,
	);
	const cacheOutdated = workflowConfigChanges !== "" || webSearchConfigChanges !== "";
	return cacheOutdated;
}

// get the Alfred keywords and write them to the cachePath
// PERF Saving keywords in a cache saves ~250ms for me (50+ workflows, 180+ keywords)
/** @param {string} cachePath */
function refreshKeywordCache(cachePath) {
	const timelogStart = +new Date();

	const keywords = app
		// `grep -v "$(basename "$PWD")"` removes results from this folder, since
		// they do not not need to be ignored by Alfred.
		// (Removing by a hardcoded foldername would not work, since Alfred
		// assigns a unique ID to local installations. )
		.doShellScript(
			'grep -A1 "<key>keyword" ../**/info.plist | grep "<string>" | grep -v "$(basename "$PWD")"',
		)
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
					// `..` is already the Alfred preferences directory, so no need to `cd` there
					const userKeyword = app.doShellScript(
						`plutil -extract "${varName}" raw -o - "${workflowPath}/prefs.plist"`,
					);
					keywords.push(userKeyword);
				} catch (_error) {
					// CASE 1b: keywords where user kept the default value
					const workflowConfig = JSON.parse(
						app.doShellScript(
							`plutil -extract "userconfigurationconfig" json -o - "${workflowPath}/info.plist"`,
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
	// CASE 5: Pre-installed Searches
	app
		.doShellScript(
			"grep --files-without-match 'disabled' ../../preferences/features/websearch/**/prefs.plist | " +
				"xargs -I {} grep -A1 '<key>keyword' '{}' | grep '<string>'",
		)
		.split("\r")
		.forEach((line) => {
			const searchKeyword = line.split(">")[1].split("<")[0];
			keywords.push(searchKeyword);
		});
	// CASE 6: User Searches
	const userSearches = JSON.parse(
		app.doShellScript("plutil -convert json ../../preferences/features/websearch/prefs.plist -o -"),
	).customSites;
	Object.keys(userSearches).forEach((uuid) => {
		const searchObj = userSearches[uuid];
		if (searchObj.enabled) keywords.push(searchObj.keyword);
	});

	const uniqueKeywords = [...new Set(keywords)];

	const durationTotalSecs = (+new Date() - timelogStart) / 1000;
	console.log(`Rebuilt cache: ${uniqueKeywords.length} keywords, ${durationTotalSecs}s`);
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
	const userIsTyping = query !== oldQuery;
	if (userIsTyping) {
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
		// (less than 40ms difference between 1 and 25 results), so there is no use
		// in restricting the number of results for performance. (Except for 25 being
		// ddgr's maximum)
		const ddgrCommand = `ddgr --noua ${includeUnsafe} --num=${resultsToFetch} --json "${query}"`;
		const response = {
			results: JSON.parse(app.doShellScript(ddgrCommand)),
			query: query,
		};
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
		rerun: 0.1, // HACK has to permanently rerun to pick up changes from multi-select
		skipknowledge: true, // so Alfred does not change result order for multi-select
		variables: { oldResults: JSON.stringify(newResults), oldQuery: query },
		items: [searchForQuery].concat(newResults),
	});

	const durationTotalSecs = (+new Date() - timelogStart) / 1000;
	let log = `Total: ${durationTotalSecs}s`;
	if (mode !== "default") log += ` (${mode})`;
	console.log(log);

	return alfredInput;
}
