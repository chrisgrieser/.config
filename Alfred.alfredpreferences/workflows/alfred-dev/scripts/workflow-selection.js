#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const items = app
		.doShellScript("ls -t ..") // workflow folders, sorted by recency
		.split("\r")
		.map((workflowUid) => {
			// workflowUid == name of workflow folder
			const workflowName = app.doShellScript(
				`plutil -extract "name" raw -o - "../${workflowUid}/info.plist"`,
			);

			return {
				title: workflowName,
				arg: workflowUid,
				uid: workflowUid,
				icon: { path: `../${workflowUid}/icon.png` },
			};
		});

	return JSON.stringify({
		items: items,
		cache: { seconds: 1800, loosereload: true },
	});
}
