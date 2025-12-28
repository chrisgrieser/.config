#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {number} timestamp @return {string} relative date */
function getRelativeDate(timestamp) {
	const deltaMins = (Date.now() - timestamp) / 1000 / 60;
	let /** @type {"year"|"month"|"week"|"day"|"hour"|"minute"} */ unit;
	let delta;
	if (deltaMins < 60) {
		unit = "minute";
		delta = Math.floor(deltaMins);
	} else if (deltaMins < 60 * 24) {
		unit = "hour";
		delta = Math.floor(deltaMins / 60);
	} else if (deltaMins < 60 * 24 * 7) {
		unit = "day";
		delta = Math.floor(deltaMins / 60 / 24);
	} else if (deltaMins < 60 * 24 * 7 * 4) {
		unit = "week";
		delta = Math.floor(deltaMins / 60 / 24 / 7);
	} else if (deltaMins < 60 * 24 * 7 * 4 * 12) {
		unit = "month";
		delta = Math.floor(deltaMins / 60 / 24 / 7 / 4);
	} else {
		unit = "year";
		delta = Math.floor(deltaMins / 60 / 24 / 7 / 4 / 12);
	}
	const formatter = new Intl.RelativeTimeFormat("en", { style: "narrow", numeric: "auto" });
	return formatter.format(-delta, unit);
}

//------------------------------------------------------------------------------

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const sqlPath = "$HOME/Library/Containers/com.chabomakers.Antinote/Data/Documents/notes.sqlite3";
	const sqlQuery = "SELECT id,lastModified,content FROM notes ORDER BY lastModified DESC";
	const out = app.doShellScript(`sqlite3 -json "${sqlPath}" "${sqlQuery}"`);

	// DOCS https://antinote.io/user-manual?#url-schemes
	/** @type {AlfredItem[]} */
	const alfredItems = JSON.parse(out).map((/** @type {any} */ item) => {
		const { id, lastModified, content } = item;
		const timestamp = new Date(lastModified + "Z").getTime();
		const title = content.trim().replaceAll("\n", " – ") || "(empty note)";

		return {
			title: title,
			subtitle: getRelativeDate(timestamp),
			arg: id,
			mods: {
				cmd: { arg: content }, // copy content
			},
		};
	});

	return JSON.stringify({ items: alfredItems });
}
