#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const readLaterItems = readFile($.getenv("read_later_file"))
		.trim()
		.split("\n")
		.filter((line) => line.startsWith("- [ ] "))
		.map((line) => {
			const title = line.split("](")[0].slice(7);
			const url = line.split("](")[1].slice(0, -1);
			return {
				title: title,
				subtitle: url,
				arg: url,
			};
		});

	// GUARD
	if (readLaterItems.length === 0) {
		readLaterItems.push({
			title: "Reading List empty.",
			subtitle: "Press ↵ to open Feedreader.",
			arg: $.getenv("feedreaderURL"),
		})
	} else {
		readLaterItems.unshift({
			title: "🔖 Add current browser tab",
			subtitle: "",
			arg: "add",
		})
	} 

	return JSON.stringify({ items: readLaterItems });
}
