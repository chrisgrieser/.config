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
	// OPEN
	// PERF open first do the rest in the background
	const selectedUrl = argv[0];
	app.openLocation(selectedUrl);

	//───────────────────────────────────────────────────────────────────────────
	// SAVE READING POSITION AND MARK AS READ 

	const curSubreddit = readFile($.getenv("alfred_workflow_cache") + "/current_subreddit");
	const subredditCachePath = `${$.getenv("alfred_workflow_cache")}/${curSubreddit}.json`;
	/** @type{AlfredItem[]} */
	const subredditCache = JSON.parse(readFile(subredditCachePath));
	const selectedItemIdx = subredditCache.findIndex(
		(item) => item.arg === selectedUrl || item.mods.shift.arg === selectedUrl,
	);

	// mark the selected item as visited such for the next run
	const visitedIcon = "🟪 ";
	subredditCache[selectedItemIdx].title = visitedIcon + subredditCache[selectedItemIdx].title;

	// change the order, so that the part scrolled over goes to the bottom, and
	// the part not scrolled over gets to the top.
	const reorderItems = $.getenv("save_scroll_position") === "1";
	if (reorderItems) {
		// using `Infinity` to always read till the end of the array. Using `splice`
		// over `slice` so we also change the original array in-place
		const unreadCache = subredditCache.splice(selectedItemIdx + 1, Infinity);
		const reOrderedCache = unreadCache.concat(subredditCache);
		writeToFile(subredditCachePath, JSON.stringify(reOrderedCache));
	}
}
