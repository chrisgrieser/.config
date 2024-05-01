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
 * @property {string?} breadcrumbs // additional property for this workflow
 */

//──────────────────────────────────────────────────────────────────────────────

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
			acc = recursivelyGetBookmarks(child, acc, breadcrumbs + "/" + item.name);
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
	for (const key in bookmarkJson) {
		const bms = recursivelyGetBookmarks(bookmarkJson[key], [], "");
		allBookmarks = allBookmarks.concat(bms);
	}

	const bookmarks = allBookmarks.map((bookmark) => {
		const { name, url, breadcrumbs } = bookmark;

		return {
			title: name,
			match: alfredMatcher(name),
			subtitle: breadcrumbs || "?",
			arg: url,
		};
	});

	return JSON.stringify({
		items: bookmarks,
		// cache: { seconds: 60 * 5, loosereload: true },
	});
}
