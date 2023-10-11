#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// guard: cache was not updated
	const cachesUpToDate = $.getenv("cacheWasUpdated") === "false";
	if (cachesUpToDate) return;

	// IMPORT SUBREDDIT-LOADING-FUNCTIONS
	// HACK read + eval, since JXA knows no import keyword
	const fileToImport =
		$.getenv("alfred_preferences") +
		"/workflows/" +
		$.getenv("alfred_workflow_uid") + // = foldername
		"/scripts/get-new-posts.js";
	eval(readFile(fileToImport));

	// determine the other subreddits
	const curSubreddit = readFile($.getenv("alfred_workflow_cache") + "/current_subreddit");
	const allSubreddits = $.getenv("subreddits").split("\n");
	if ($.getenv("add_hackernews") === "1") allSubreddits.push("hackernews");
	const otherSubreddits = allSubreddits.filter((subreddit) => subreddit !== curSubreddit);

	// reload cache for them
	for (const subredditName of otherSubreddits) {
		const subredditCache = `${$.getenv("alfred_workflow_cache")}/${subredditName}.json`;
		console.log("Reloading cache for " + subredditName);

		// read old cache
		const oldCache = fileExists(subredditCache) ? JSON.parse(readFile(subredditCache)) : [];

		const posts =
			// biome-ignore lint/correctness/noUndeclaredVariables: import HACK
			subredditName === "hackernews" ? getHackernewsPosts(oldCache) : getRedditPosts(subredditName, oldCache);

		writeToFile(subredditCache, JSON.stringify(posts));
	}
}
