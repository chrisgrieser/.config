#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const shellCmd = "ls"
	/** @type {AlfredItem[]} */
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
