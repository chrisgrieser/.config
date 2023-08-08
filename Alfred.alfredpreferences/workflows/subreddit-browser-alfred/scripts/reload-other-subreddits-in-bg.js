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
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// guard: cache was not updated
	const cacheWasUpdated = $.getenv("cache_was_updated") === "true";
	if (!cacheWasUpdated) return;

	// import subreddit-loading-functions
	// HACK read + eval, since JXA knows no import keyword
	const fileToImport = readFile("./scripts/browse-subreddits.js");
	console.log("[QL] fileToImport:", fileToImport);
	eval(fileToImport);
	if (true) return

	const curSubreddit = readFile($.getenv("alfred_workflow_cache") + "/current_subreddit");
	const otherSubreddits = $.getenv("subreddits")
		.split("\n")
		.filter((subreddit) => subreddit !== curSubreddit);

	otherSubreddits.forEach((subredditName) => {
		const subredditCache = `${$.getenv("alfred_workflow_cache")}/${subredditName}.json`;

		// read old cache
		const oldUrls = fileExists(subredditCache)
			? JSON.parse(readFile(subredditCache)).map((/** @type {AlfredItem} */ item) => item.arg)
			: [];

		const posts =
			// rome-ignore lint/correctness/noUndeclaredVariables: import HACK
			subredditName === "hackernews" ? getHackernewsPosts(oldUrls) : getRedditPosts(subredditName, oldUrls);

		writeToFile(subredditCache, JSON.stringify(posts));
	});
}
