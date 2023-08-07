#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// PERF open first do the rest in the background
	const selectedUrl = argv[0];
	app.openLocation(selectedUrl);

	// PERF re-order the cache now, so next run is done quicker
	// also simplifies code by being able to manage everything in this one file
	const curSubreddit = readFile($.getenv("alfred_workflow_cache") + "/current_subreddit");
	const subredditCachePath = `${$.getenv("alfred_workflow_cache")}/${curSubreddit}.json`;

	/** @type{AlfredItem[]} */
	const subredditCache = JSON.parse(readFile(subredditCachePath));
	const selectedItemIdx = subredditCache.findIndex((item) => item.arg === selectedUrl);
}
