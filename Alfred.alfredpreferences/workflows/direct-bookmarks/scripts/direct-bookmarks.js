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

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

//──────────────────────────────────────────────────────────────────────────────
/** @typedef {Object} bookmark
 * @property {number} date_added
 * @property {string} name
 * @property {string} url
 * @property {"url"|"folder"} type
 * @property {bookmark[]?} children // only for folders
 * @property {string?} breadcrumbs // additional property for this workflow
 */

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_.]/g, " ");
	const joined = str.replace(/[-_.]/g, "");
	return [clean, str, joined].join(" ").toLowerCase() + " ";
}

/**
 * @param {bookmark} item
 * @param {bookmark[]} acc
 * @param {string} breadcrumbs
 * @return {bookmark[]} flattened
 */
function recursivelyGetBookmarks(item, acc, breadcrumbs) {
	if (item.type === "url") {
		item.breadcrumbs = breadcrumbs;
		acc.push(item);
	} else if (item.type === "folder") {
		for (const child of item.children || []) {
			const trail = breadcrumbs ? breadcrumbs + "/" + item.name : item.name;
			acc = recursivelyGetBookmarks(child, acc, trail);
		}
	}
	return acc;
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

/**
 * @param {string} path1
 * @param {string} path2
 * @return {boolean}
 */
function fileOlderThan(path1, path2) {
	const file1 = Application("System Events").aliases[path1];
	if (!file1.exists()) return false;
	const file2 = Application("System Events").aliases[path2];
	return file1.modificationDate() < file2.modificationDate();
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = $.getenv("alfred_workflow_keyword") + argv[0];
	ensureCacheFolderExists();
	const cachePath = $.getenv("alfred_workflow_cache") + "/direct-bookmarks";

	const home = app.pathTo("home folder");
	const browserDefaultsPath = $.getenv("browser_defaults_path");
	const bookmarkPath = `${home}/Library/Application Support/${browserDefaultsPath}/Default/Bookmarks`;
	let bookmarks;

	if (fileOlderThan(bookmarkPath, cachePath)) {
		bookmarks = JSON.parse(readFile(cachePath));
	} else {
		const bookmarkJson = JSON.parse(readFile(bookmarkPath)).roots;

		/** @type {bookmark[]} */
		let allBookmarks = [];
		for (const key in bookmarkJson) {
			const flattenedBms = recursivelyGetBookmarks(bookmarkJson[key], [], "");
			allBookmarks = allBookmarks.concat(flattenedBms);
		}

		bookmarks = allBookmarks.map((bookmark) => {
			const { name, url, breadcrumbs } = bookmark;
			const matcher = alfredMatcher(name) + alfredMatcher(breadcrumbs || "");
			const subtitle = (breadcrumbs || "").replace(/^Bookmarks\//, "") + "     " + url;

			return {
				title: name,
				matchStr: matcher,
				subtitle: subtitle,
				arg: url,
			};
		});

		writeToFile(cachePath, JSON.stringify(bookmarks));
	}

	//───────────────────────────────────────────────────────────────────────────
	// MATCHING BEHAVIOR
	const queryRegex = new RegExp("\\b" + query, "i");
	bookmarks = bookmarks.filter((/** @type {{matchStr: string}} */ bookmark) =>
		bookmark.matchStr.match(queryRegex),
	);

	return JSON.stringify({ items: bookmarks });
}
