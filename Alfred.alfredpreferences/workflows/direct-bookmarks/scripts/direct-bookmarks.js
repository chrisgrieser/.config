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

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\;,[\]]/g, " ");
	return [clean, str].join(" ") + " ";
}

/** @typedef {Object} bookmark
 * @property {number} date_added
 * @property {number} date_last_used
 * @property {number} guid
 * @property {number} id
 * @property {string} name
 * @property {string} url
 * @property {"url"|"folder"} type
 * @property {bookmark[]?} children
 */

//──────────────────────────────────────────────────────────────────────────────

/**
 * @param {bookmark} item
 * @param {bookmark[]=} acc
 * @return {bookmark[]} flattened
 */
function recursivelyGetBookmarks(item, acc) {
	if (!acc) acc = [];
	console.log("⭕ acc:", acc.length);
	if (item.type === "url") {
		acc.push(item);
	} else if (item.type === "folder" && item.children) {
		for (const child of item.children) {
			const childBookmarks = recursivelyGetBookmarks(child, acc);
			acc.push(...childBookmarks);
		}
	}
	return acc;
}

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const bookmarkPath =
		app.pathTo("home folder") +
		"/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks";
	const bookmarkJson = JSON.parse(readFile(bookmarkPath)).roots;

	/** @type {bookmark[]} */
	let allBookmarks = [];
	// for (const key in bookmarkJson) {
	// 	const bms = recursivelyGetBookmarks(bookmarkJson[key]);
	// 	allBookmarks = allBookmarks.concat(bms);
	// }
	allBookmarks = recursivelyGetBookmarks(bookmarkJson.bookmark_bar);

	const bookmarks = allBookmarks.map((bookmark) => {
		const { name, url } = bookmark;

		return {
			title: name,
			match: alfredMatcher(name),
			subtitle: url,
			arg: url,
		};
	});

	return JSON.stringify({
		items: bookmarks,
		// cache: { seconds: 60 * 5, loosereload: true },
	});
}
