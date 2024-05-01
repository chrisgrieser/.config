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
	const clean = str.replace(/[-_.]/g, " ");
	const joined = str.replace(/[-_.]/g, "");
	return [clean, str, joined].join(" ").toLowerCase() + " ";
}

/** @typedef {Object} bookmark
 * @property {number} date_added
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
			const trail = breadcrumbs ? breadcrumbs + "/" + item.name : item.name;
			acc = recursivelyGetBookmarks(child, acc, trail);
		}
	}
	return acc;
}

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = ($.getenv("alfred_workflow_keyword") + argv[0]).toLowerCase();

	const home = app.pathTo("home folder");
	const browserDefaultsPath = $.getenv("browser_defaults_path");
	const bookmarkPath = `${home}/Library/Application Support/${browserDefaultsPath}/Default/Bookmarks`;
	const bookmarkJson = JSON.parse(readFile(bookmarkPath)).roots;

	/** @type {bookmark[]} */
	let allBookmarks = [];
	for (const key in bookmarkJson) {
		const flattenedBms = recursivelyGetBookmarks(bookmarkJson[key], [], "");
		allBookmarks = allBookmarks.concat(flattenedBms);
	}

	const bookmarks = allBookmarks.map((bookmark) => {
		const { name, url, breadcrumbs } = bookmark;
		const matcher = alfredMatcher(name) + alfredMatcher(breadcrumbs || "");
		if (!matcher.includes(query)) return {};

		const subtitle = (breadcrumbs || "").replace(/^Bookmarks\//, "") + "    " + url;

		return {
			title: name,
			match: matcher,
			subtitle: subtitle,
			arg: url,
		};
	});

	return JSON.stringify({ items: bookmarks });
}
