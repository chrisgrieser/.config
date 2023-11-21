#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");

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
	let lineNo = 0;

	/** @type AlfredItem[] */
	const todos = readFile($.getenv("todotxt_filepath"))
		.split("\n")
		.map((item) => {
			lineNo++;
			return {
				title: item,
				subtitle: item,
				arg: lineNo,
				a,
			};
		});

	return JSON.stringify({ items: todos });
}
