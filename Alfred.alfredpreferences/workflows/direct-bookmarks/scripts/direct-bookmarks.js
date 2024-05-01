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

//──────────────────────────────────────────────────────────────────────────────

function recursivlyGetBookmarks(child) {
	if
}

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const bookmarkPath = ""

	const bookmarkJson = JSON.parse(readFile(bookmarkPath))


	const bookmarks = []
	return JSON.stringify({ items: bookmarks });
}
