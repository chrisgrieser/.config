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

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(){
	const cachePath = $.getenv("alfred_workflow_cache") + "/pypi-index.json";
	if (!fileExists(cachePath)) {
		return JSON.stringify({ items: [{
			title: "Pypi Index does not exist.",
			subtitle: "Run `:pip` to create it.",
		}] });
	}

	return readFile(cachePath);
}

