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

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const mode = $.getenv("mode");
	const readLaterFile = $.getenv("read_later_file");
	const items = readFile(readLaterFile).trim().split("\n");

	const lineNo = Number.parseInt(argv[0]);
	const selectedLine = items[lineNo - 1];

	// mark item as read
	items[lineNo - 1] = selectedLine.replace("- [ ] ", "- [x] ");
	writeToFile(readLaterFile, items.join("\n"));

	// open URL
	if (mode === "open") {
		const url = selectedLine.split("](")[1].split(")")[0];
		app.openLocation(url);
	}
}
