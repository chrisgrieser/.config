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

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const progressFile = $.getenv("alfred_workflow_cache") + "/stdout"
	const progressInfo = readFile(progressFile);

	const items = app
		.doShellScript(shellCmd)
		.split("\r")
		.map((item) => {
			/** @type {AlfredItem} */
			const alfredItem = {
				title: item,
				subtitle: item,
				arg: item,
			};
			return alfredItem;
		});

	return JSON.stringify({ items: items });
}
