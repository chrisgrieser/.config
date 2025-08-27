#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const dlFolder = $.getenv("download_folder");
	// each `.stdout` file represents one ongoing download
	// getting the last line from each -> progress for each
	const shellCmd = `tail --silent --lines=1 "$alfred_workflow_cache"/*.stdout || true`;

	/** @type {AlfredItem[]} */
	const downloads = app
		.doShellScript(shellCmd)
		.split("\r")
		.filter((item) => item !== "") // empty when no download in progress
		.map((item) => {
			const delimiter = ";"; // set in `--progress-template`
			const [videoTitle, info] = item.split(delimiter);
			return {
				title: info.trim(),
				subtitle: videoTitle,
				arg: dlFolder,
			};
		});
	if (downloads.length === 0) downloads.push({
		title: "No downloads in progress",
		subtitle: "⏎: Open download folder",
		arg: dlFolder,
	});

	return JSON.stringify({
		items: downloads,
		rerun: 0.5, // update for new progress
	});
}
