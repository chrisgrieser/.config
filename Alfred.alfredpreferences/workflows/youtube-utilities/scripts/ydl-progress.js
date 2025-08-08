#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// each `.stdout` file represents one ongoing download
	// getting the last line from each -> progress for each
	const shellCmd = `tail --silent --lines=1 "$alfred_workflow_cache"/*.stdout`;

	/** @type {AlfredItem[]} */
	const downloadsInProgress = app
		.doShellScript(shellCmd)
		.split("\r")
		.map((item) => {
			return {
				title: item,
				subtitle: "",
				valid: false, // since not actionable
			};
		});
	
	if (downloadsInProgress.length === 0) {
		return JSON.stringify({ items: [] });
	}

	return JSON.stringify({
		items: downloadsInProgress,
		rerun: 0.5, // update for new progress
	});
}
