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
	let cacheAgeThresholdMins = parseInt($.getenv("cache_age_threshold")) || 15;
	if (cacheAgeThresholdMins < 1) cacheAgeThresholdMins = 1; // prevent 0 or negative numbers
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeMins = (+new Date() - cacheObj.creationDate()) / 1000 / 60;
	return cacheAgeMins > cacheAgeThresholdMins;
}

/**
 * @param {string} firstPath
 * @param {string} secondPath
 * @returns {boolean} firstPathOlderThanSecond
 */
function olderThan(firstPath, secondPath) {
	const firstMdate = +Application("System Events").aliases[firstPath].modificationDate();
	const secondMdate = +Application("System Events").aliases[secondPath].modificationDate();
	const firstPathOlderThanSecond = firstMdate - secondMdate < 0;
	return firstPathOlderThanSecond;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const timelogStart = +new Date();

	// determine subreddit
	const prevRunSubreddit = readFile($.getenv("alfred_workflow_cache") + "/current_subreddit");
	const selectedWithAlfred = $.NSProcessInfo.processInfo.environment.objectForKey("selected_subreddit").js;
	const firstSubredditInConfig = $.getenv("subreddits").split("\n")[0]; // only needed for first run
	const subredditName = selectedWithAlfred || prevRunSubreddit || firstSubredditInConfig;
	const pathOfThisWorkflow = `${$.getenv("alfred_preferences")}/workflows/${$.getenv("alfred_workflow_uid")}`;

	ensureCacheFolderExists();
	writeToFile($.getenv("alfred_workflow_cache") + "/current_subreddit", subredditName);

	// read posts from cache
	const subredditCache = `${$.getenv("alfred_workflow_cache")}/${subredditName}.json`;

	let posts;
	if (!cacheIsOutdated(subredditCache) && olderThan(`${pathOfThisWorkflow}/prefs.plist`, subredditCache)) {
		posts = JSON.parse(readFile(subredditCache));
		return JSON.stringify({
			variables: { cacheWasUpdated: "false" }, // Alfred vars always strings
			skipknowledge: true, // workflow handles order to remember reading positions
			items: posts,
		});
	}

	// IMPORT SUBREDDIT-LOADING-FUNCTIONS
	// HACK read + eval, since JXA knows no import keyword
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
		return JSON.stringify({ items: [{ title: "No Posts higher than minimum upvote count" }] });
	}

	writeToFile(subredditCache, JSON.stringify(posts));

	const durationSecs = (+new Date() - timelogStart) / 1000;
	console.log("Total", durationSecs, "s");

	return JSON.stringify({
		variables: { cacheWasUpdated: "true" }, // Alfred vars always strings
		items: posts,
	});
}
