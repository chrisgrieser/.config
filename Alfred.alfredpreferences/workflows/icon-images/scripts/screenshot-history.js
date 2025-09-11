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
	// -l: long format, -t: sort by time, -h: human readable sizes
	// `tail -n+2` to remove header
	// `awk` to only print name & filesize
	const shellCmd = `ls -lht "${screenshotTempDir}" | tail -n+2 | awk '{print $5, $9}'`;

	/** @type {AlfredItem[]} */
	const alfredItems = app
		.doShellScript(shellCmd)
		.split("\r")
		// .slice(1) // remove header
		.map((line) => {
			const [filesize, name] = line.split(" ");
			const absPath = `${screenshotTempDir}/${name}`;

			const isoStr = name.replace(/Screenshot_([\d-]+)_(\d+)-(\d+)-(\d+).png/, "$1T$2:$3:$4");
			const relDate = relativeDate(new Date(isoStr).getTime());
			const prettyFilesize = filesize.replace(/(\d+)K/, "$1 Kb")

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
