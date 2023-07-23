#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib")
const app = Application.currentApplication()
app.includeStandardAdditions = true;

/** @param {string} text @param {string} filepath */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv){
	const url = argv[0];
}

