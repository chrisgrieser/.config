#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @typedef {Object} ddgrResponse (of the fork)
 * @property {string} instant_answer
 * @property {ddgrResult[]} results
 * @property {string?} query (manually added by this workflow for the cache)
 */

/** @typedef {Object} ddgrResult
 * @property {string} title
 * @property {string} abstract
 * @property {string} url
 */

//──────────────────────────────────────────────────────────────────────────────
// CONFIG

let resultsToFetch = parseInt($.getenv("inline_results_to_fetch")) || 5;
if (resultsToFetch < 1) resultsToFetch = 1;
else if (resultsToFetch > 25) resultsToFetch = 25; // maximum supported by `ddgr`

const minimumQueryLength = parseInt($.getenv("minimum_query_length")) || 3;
if (minimumQueryLength < 0) resultsToFetch = 0;
else if (minimumQueryLength > 10) resultsToFetch = 10; // prevent accidental high values

const includeUnsafe = $.getenv("include_unsafe") === "1" ? "--unsafe" : "";
const ignoreAlfredKeywordsEnabled = $.getenv("ignore_alfred_keywords") === "1";
const multiSelectIcon = $.getenv("multi_select_icon") || "🔳";

// https://duckduckgo.com/duckduckgo-help-pages/settings/params/
const searchRegion = $.getenv("region") === "none" ? "" : "--reg=" + $.getenv("region");

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
	return webSearchConfigChanges || workflowConfigChanges;
}

// get the Alfred keywords and write them to the cachePath
// PERF Saving keywords in a cache saves ~250ms for me (50+ workflows, 180+ keywords)
/** @param {string} cachePath */
function refreshKeywordCache(cachePath) {
	console.log("Refreshing keyword cache…");
	const timelogStart = +new Date();

	const keywords = app
		// $alfred_workflow_uid is identical with this workflow's foldername, which
		// is excluded from the results, since this workflows keywords do not need
		// to be removed
		.doShellScript(
			'grep -A1 "<key>keyword" ../**/info.plist | grep "<string>" | grep -v "$alfred_workflow_uid" || true',
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
				// CASE 1a: user-set keywords
				// (wrapped in try, since `plutil` will fail, as the value isn't saved in prefs.plist)
				try {
					// `..` is already the Alfred preferences directory, so no need to `cd` there
					const userKeyword = app.doShellScript(
						`plutil -extract "${varName}" raw -o - "${workflowPath}/prefs.plist"`,
					);
					keywords.push(userKeyword);
				} catch (_error) {
					// CASE 1b: keywords where user kept the default value
					try {
						const workflowConfig = JSON.parse(
							app.doShellScript(
								`plutil -extract "userconfigurationconfig" json -o - "${workflowPath}/info.plist"`,
							),
						);
						const defaultValue = workflowConfig.find(
							(/** @type {{ variable: string; }} */ option) => option.variable === varName,
						).config.default;
						keywords.push(defaultValue);
					} catch (_error) {}
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

			acc.push(...keywords);
			return acc;
		}, []);

	// CASE 5: Pre-installed Searches
	const preinstalledSearches = app.doShellScript(
		"grep --files-without-match 'disabled' ../../preferences/features/websearch/**/prefs.plist | " +
			"xargs -I {} grep -A1 '<key>keyword' '{}' | grep '<string>' || true",
	);
	// check for the possibility of user having all searches disabled
	if (preinstalledSearches) {
		preinstalledSearches.split("\r").forEach((line) => {
			const searchKeyword = line.split(">")[1].split("<")[0];
			keywords.push(searchKeyword);
		});
	}

	// CASE 6: User Searches
	const userSearches = JSON.parse(
		app.doShellScript("plutil -convert json ../../preferences/features/websearch/prefs.plist -o - || true") ||
			"{}",
	).customSites;
	if (userSearches) {
		Object.keys(userSearches).forEach((uuid) => {
			const searchObj = userSearches[uuid];
			if (searchObj.enabled) keywords.push(searchObj.keyword);
		});
	}

	// CASE 7: Keywords from this workflow
	// (not covered by earlier cases, since the workflow folder is excluded to
	// prevent the addition of the pseudo-keywords "a, b, c, …" in the list of
	// ignored keywords.)
	keywords.push("today");

	// FILTER IRRELEVANT KEYWORDS
	// - also only the first word of a keyword matters
	// - only keywords with letter as first char are relevant
	const relevantKeywords = keywords.reduce((acc, keyword) => {
		const firstWord = keyword.split(" ")[0];
		if (firstWord.match(/^[a-z]/)) acc.push(firstWord);
		return acc;
	}, []);
	const uniqueKeywords = [...new Set(relevantKeywords)];
	writeToFile(cachePath, JSON.stringify(uniqueKeywords));

	// LOGGING
	const durationTotalSecs = (+new Date() - timelogStart) / 1000;
	console.log(`Rebuilt keyword cache (${uniqueKeywords.length} keywords) in ${durationTotalSecs}s`);
}

//──────────────────────────────────────────────────────────────────────────────
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const timelogStart = +new Date();

	/** @type{"fallback"|"multi-select"|"default"|"rerun"} */
	let mode = $.NSProcessInfo.processInfo.environment.objectForKey("mode").js || "default";
	const neverIgnore = mode === "fallback" || mode === "multi-select";

	// HACK script filter is triggered with any letter of the roman alphabet, and
	// then prepended here, to trigger this workflow with any search term
	const scriptFilterKeyword =
		$.NSProcessInfo.processInfo.environment.objectForKey("alfred_workflow_keyword").js || "";
	const query = (scriptFilterKeyword + argv[0]).trim();

	// ensure cache folder exists
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (!finder.exists(Path(cacheDir))) {
		console.log("Cache Dir does not exist and is created.");
		const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
		finder.make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: cacheDirBasename },
		});
	}

	// GUARD CLAUSE 1: query is URL or too short
	if (query.match(/^\w+:/) && !neverIgnore) {
		console.log("Ignored (URL)");
		return;
	} else if (query.length < minimumQueryLength && !neverIgnore) {
		console.log("Ignored (Min Query Length)");
		return;
	}

	// GUARD CLAUSE 2: extra ignore keywords
	const ignoreExtraWordsStr = $.getenv("ignore_extra_words");
	if (ignoreExtraWordsStr !== "" && !neverIgnore) {
		const ignoreExtraWords = ignoreExtraWordsStr.split(/ ?, ?/);
		const queryFirstWord = query.split(" ")[0];
		if (ignoreExtraWords.includes(queryFirstWord)) {
			console.log("Ignored (extra ignore word)");
			return;
		}
	}

	// GUARD CLAUSE 3: first word of query is Alfred keyword
	// (guard clause is ignored when doing fallback search or multi-select,
	// since in that case we know we do not need to ignore anything.)
	if (ignoreAlfredKeywordsEnabled && !neverIgnore) {
		const keywordCachePath = $.getenv("alfred_workflow_cache") + "/alfred_keywords.json";
		if (keywordCacheIsOutdated(keywordCachePath)) refreshKeywordCache(keywordCachePath);
		const alfredKeywords = JSON.parse(readFile(keywordCachePath));
		const queryFirstWord = query.split(" ")[0];
		if (alfredKeywords.includes(queryFirstWord)) {
			console.log(`Ignored (Alfred keyword: ${queryFirstWord})`);
			return;
		}
	}

	// GUARD CLAUSE 4: use old results
	// -> get values from previous run
	const oldQuery = $.NSProcessInfo.processInfo.environment.objectForKey("oldQuery").js;
	const oldResults = $.NSProcessInfo.processInfo.environment.objectForKey("oldResults").js || "[]";

	const querySearchUrl = $.getenv("search_site") + encodeURIComponent(query).replaceAll("'", "%27");
	/** @type AlfredItem */
	const searchForQuery = {
		title: `"${query}"`,
		uid: query,
		arg: querySearchUrl,
	};

	// PERF & HACK If the user is typing, return early to guarantee the top entry
	// is the currently typed query. If we waited for `ddgr`, a fast typer would
	// search for an incomplete query.
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
	/** @type{ddgrResponse} */
	const responseCache = JSON.parse(readFile(responseCachePath) || "{}");
	/** @type{ddgrResponse} */
	let response;

	if (responseCache.query === query) {
		response = responseCache;
		mode = "rerun";
	} else {
		// NOTE using a fork of ddgr which includes the instant_answer when using `--json`
		// https://github.com/kometenstaub
		// PERF `--noua` disables user agent & fetches faster (~100ms according to hyperfine)
		// PERF the number of results fetched has basically no effect on the speed
		// (less than 40ms difference between 1 and 25 results), so there is no use
		// in restricting the number of results for performance. (Except for 25 being
		// ddgr's maximum)
		const escapedQuery = query.replaceAll('"', '\\"');
		const ddgr = "python3 ./dependencies/ddgr.py"
		const ddgrCmd = `${ddgr} --json --noua ${includeUnsafe} --num=${resultsToFetch} ${searchRegion} "${escapedQuery}"`;
		response = JSON.parse(app.doShellScript(ddgrCmd));
		response.query = query;
		writeToFile(responseCachePath, JSON.stringify(response));
	}

	// INSTANT ANSWER
	if (response.instant_answer) searchForQuery.subtitle = response.instant_answer;

	// determine multi-select items
	const multiSelectBufferPath = $.getenv("alfred_workflow_cache") + "/multiSelectBuffer.txt";
	const multiSelectUrls = readFile(multiSelectBufferPath).split("\n") || [];

	// RESULTS
	/** @type AlfredItem[] */
	const newResults = response.results.map((item) => {
		const isSelected = multiSelectUrls.includes(item.url);
		const icon = isSelected ? multiSelectIcon + " " : "";
		const topLevelDomain = item.url.replace(/^https?:\/\/(?:www.)?(.*?)\/.*/, "$1");
		return {
			title: icon + item.title,
			subtitle: topLevelDomain,
			uid: item.url,
			arg: isSelected ? "" : item.url, // if URL already selected, no need to pass it
			icon: { path: "icons/1.png" },
			mods: {
				shift: { subtitle: item.abstract },
				alt: { subtitle: `⌥: Copy  ➙  ${item.url}` }, // also makes holding alt show the full URL
				cmd: {
					arg: item.url, // has to be set, since main arg can be ""
					variables: { mode: "multi-select" },
					subtitle: isSelected ? "⌘: Deselect URL" : "⌘: Select URL",
				},
			},
		};
	});

	// MULTI-SLECT: searchForQuery
	if (multiSelectUrls.includes(querySearchUrl)) {
		searchForQuery.title = multiSelectIcon + " " + searchForQuery.title;
		searchForQuery.mods = {
			cmd: {
				arg: querySearchUrl, // has to be set again, since main arg can be ""
				variables: { mode: "multi-select" },
				subtitle: "⌘: Deselect URL",
			},
		};
		searchForQuery.arg = ""; // if URL already selected, no need to pass it
	}

	//───────────────────────────────────────────────────────────────────────────

	// Pass to Alfred
	const alfredInput = JSON.stringify({
		rerun: 0.1, // HACK has to permanently rerun to pick up changes from multi-select
		skipknowledge: true, // so Alfred does not change result order for multi-select
		variables: { oldResults: JSON.stringify(newResults), oldQuery: query },
		items: [searchForQuery].concat(newResults),
	});

	// logging
	const durationTotalSecs = (+new Date() - timelogStart) / 1000;
	let log = `${durationTotalSecs}s, "${query}"`;
	if (mode === "default") log = "Total: " + log;
	// indented to make it easier to read (using `__`, since Alfred removes leading whitespace)
	else if (mode === "rerun") log = "__" + log;
	else log += ` (${mode})`;
	console.log(log);

	return alfredInput;
}
