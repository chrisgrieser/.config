#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const screenshotTempDir = "/tmp/screenshots/"
	// -l: long format, -t: sort by time, -h: human readable sizes
	// awk to only print name & filesize
	const shellCmd = `ls -lht "${screenshotTempDir}" | awk '{print $5, $9}'`

	/** @type {AlfredItem[]} */
	const alfredItems = app
		.doShellScript(shellCmd)
		.split("\r")
		.map((line) => {
			const [filesize, item] = line.split(" ");
			return {
				title: item,
				subtitle: filesize,
				arg: item,
			};
		});

	return JSON.stringify({ items: alfredItems });
}
