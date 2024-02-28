#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const items = app
		.doShellScript("cd .. && ls -t")
		.split("\r")
		.map((workflowUid) => {
			return {
				title: workflowUid,
				arg: workflowUid,
			};
		});

	return JSON.stringify({ items: items });
}
