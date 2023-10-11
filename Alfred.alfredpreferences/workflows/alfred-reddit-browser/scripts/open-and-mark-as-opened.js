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

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// identify position of selected item in the cache
	const selectedUrl = argv[0];
	const curSubreddit = readFile($.getenv("alfred_workflow_cache") + "/current_subreddit");
	const subredditCachePath = `${$.getenv("alfred_workflow_cache")}/${curSubreddit}.json`;

	if (!fileExists(subredditCachePath)) {
		console.log("No subreddit cache found");
		return;
	}

	/** @type{AlfredItem[]} */
	const subredditCache = JSON.parse(readFile(subredditCachePath));
	const selectedItemIdx = subredditCache.findIndex(
		(item) => item.arg === selectedUrl || item.mods.shift.arg === selectedUrl,
	);

	// mark the selected item as visited
	const visitedIcon = "🟪 ";
	subredditCache[selectedItemIdx].title = visitedIcon + subredditCache[selectedItemIdx].title;

	// change the order, so that the part scrolled over goes to the bottom, and
	// the part not scrolled over gets to the top.
	const reorderItems = $.getenv("save_scroll_position") === "1";
	if (reorderItems) {
		// 1. Using `splice` over `slice` so we also change the original array in-place
		// 2. for the readCache, we also remove the "new" icons
		// 3. `subredditCache` then represents the unread items, and is therefore kept on top
		const readCache = subredditCache.splice(0, selectedItemIdx + 1).map((item) => {
			item.subtitle = item.subtitle.replace("🆕 ", "");
			return item;
		});
		const reOrderedCache = subredditCache.concat(readCache);
		writeToFile(subredditCachePath, JSON.stringify(reOrderedCache));
	}
}
