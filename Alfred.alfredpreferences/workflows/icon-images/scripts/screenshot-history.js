#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {number} timestamp @return {string} relative date */
function relativeDate(timestamp) {
	const deltaHours = (Date.now() - timestamp) / 1000 / 60 / 60;
	let /** @type {"year"|"month"|"week"|"day"|"hour"|"minute"} */ unit;
	let delta;
	if (deltaHours < 1) {
		const deltaMinutes = (Date.now() - timestamp) / 1000 / 60;
		unit = "minute";
		delta = Math.floor(deltaMinutes);
	} else if (deltaHours < 24) {
		unit = "hour";
		delta = Math.floor(deltaHours);
	} else if (deltaHours < 24 * 7) {
		unit = "day";
		delta = Math.floor(deltaHours / 24);
	} else if (deltaHours < 24 * 7 * 4) {
		unit = "week";
		delta = Math.floor(deltaHours / 24 / 7);
	} else if (deltaHours < 24 * 7 * 4 * 12) {
		unit = "month";
		delta = Math.floor(deltaHours / 24 / 7 / 4);
	} else {
		unit = "year";
		delta = Math.floor(deltaHours / 24 / 7 / 4 / 12);
	}
	const formatter = new Intl.RelativeTimeFormat("en", { style: "long", numeric: "auto" });
	return formatter.format(-delta, unit);
}

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const screenshotTempDir = "/tmp/screenshots";
	const shellCmd = `stat -f "%Sm %z %N" -t "%Y-%m-%dT%H:%M:%S" ${screenshotTempDir}/*.png`;

	/** @type {AlfredItem[]} */
	const alfredItems = app
		.doShellScript(shellCmd)
		.split("\r")
		.reverse() // sort by mdate
		.map((line) => {
			const [mdate, sizeInBytes, absPath] = line.split(" ");
			const prettyFilesize = (Number.parseInt(sizeInBytes) / 1024).toFixed(0) + " Kb";
			const relDate = relativeDate(new Date(mdate).getTime());

			return {
				title: relDate,
				subtitle: prettyFilesize,
				icon: { path: absPath },
				type: "file:skipcheck",
				arg: absPath,
			};
		});

	return JSON.stringify({ items: alfredItems });
}
