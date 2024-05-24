#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

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

function ensureCacheFolderExists() {
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
}

/** @param {string} path */
function cacheIsOutdated(path) {
	const cacheAgeThresholdMins = Number.parseInt($.getenv("cache_age_threshold"));
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeMins = (+new Date() - +cacheObj.creationDate()) / 1000 / 60;
	return cacheAgeMins > cacheAgeThresholdMins;
}

/**
 * @param {string} firstPath
 * @param {string} secondPath
 * @returns {boolean} firstPathOlderThanSecond
 */
function olderThan(firstPath, secondPath) {
	const firstItem = Application("System Events").aliases[firstPath];
	if (!firstItem.exists()) return true;
	const secondItem = Application("System Events").aliases[secondPath];
	if (!secondItem.exists()) return false;
	const firstPathOlderThanSecond =
		+firstItem.modificationDate() - +secondItem.modificationDate() < 0;
	return firstPathOlderThanSecond;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const subredditConfig = $.getenv("subreddits").trim().replace(/^r\//gm, "");
	const cachePath = $.getenv("alfred_workflow_cache");

	// determine subreddit
	const prevRunSubreddit = readFile(cachePath + "/current_subreddit");
	const selectedWithAlfred =
		$.NSProcessInfo.processInfo.environment.objectForKey("selected_subreddit").js;
	const firstSubredditInConfig = subredditConfig.split("\n")[0]; // only needed for first run
	const subredditName = selectedWithAlfred || prevRunSubreddit || firstSubredditInConfig;
	const pathOfThisWorkflow =
		$.getenv("alfred_preferences") + "/workflows/" + $.getenv("alfred_workflow_uid");

	ensureCacheFolderExists();
	writeToFile(cachePath + "/current_subreddit", subredditName);

	// read posts from cache
	const subredditCache = `${cachePath}/${subredditName}.json`;

	let posts;
	const refreshIntervalPassed = cacheIsOutdated(subredditCache);
	const userPrefsUnchanged = olderThan(`${pathOfThisWorkflow}/prefs.plist`, subredditCache);
	if (!refreshIntervalPassed && userPrefsUnchanged) {
		posts = JSON.parse(readFile(subredditCache));
		return JSON.stringify({
			variables: { cacheWasUpdated: "false" }, // Alfred vars always strings
			skipknowledge: true, // workflow handles order to remember reading positions
			items: posts,
		});
	}

	//───────────────────────────────────────────────────────────────────────────

	// HACK IMPORT SUBREDDIT-LOADING-FUNCTIONS
	// biome-ignore lint/security/noGlobalEval: JXA import hack
	eval(readFile(`${pathOfThisWorkflow}/scripts/get-new-posts.js`));

	// marker for old posts
	const oldItems = fileExists(subredditCache) ? JSON.parse(readFile(subredditCache)) : [];

	// request new posts from API
	if (subredditName === "hackernews") {
		console.log("Writing new cache for hackernews");
		// biome-ignore lint/correctness/noUndeclaredVariables: JXA import HACK
		posts = getHackernewsPosts(oldItems);
	} else {
		console.log("Writing new cache for r/" + subredditName);
		// biome-ignore lint/correctness/noUndeclaredVariables: JXA import HACK
		posts = getRedditPosts(subredditName, oldItems);
	}

	// GUARD no API response or no posts left after filtering for min upvote count
	if (!posts) {
		return JSON.stringify({ items: [{ title: "Error", subtitle: "No response from API." }] });
	}
	if (posts.length === 0) {
		return JSON.stringify({ items: [{ title: "No posts higher than minimum upvote count." }] });
	}

	writeToFile(subredditCache, JSON.stringify(posts));

	return JSON.stringify({
		variables: { cacheWasUpdated: "true" }, // Alfred vars always strings
		items: posts,
	});
}
