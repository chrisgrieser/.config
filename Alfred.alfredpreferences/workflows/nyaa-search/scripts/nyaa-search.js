#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/**
 * @param {string} absoluteDateStr string to be converted to a date
 * @return {string} relative date
 */
function relativeDate(absoluteDateStr) {
	const deltaSecs = (Date.now() - +new Date(absoluteDateStr)) / 1000;
	/** @type {"year"|"month"|"week"|"day"|"hour"|"minute"|"second"} */
	let unit;
	let delta;
	if (deltaSecs < 60) {
		unit = "second";
		delta = deltaSecs;
	} else if (deltaSecs < 60 * 60) {
		unit = "minute";
		delta = Math.ceil(deltaSecs / 60);
	} else if (deltaSecs < 60 * 60 * 24) {
		unit = "hour";
		delta = Math.ceil(deltaSecs / 60 / 60);
	} else if (deltaSecs < 60 * 60 * 24 * 7) {
		unit = "day";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24);
	} else if (deltaSecs < 60 * 60 * 24 * 7 * 4) {
		unit = "week";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24 / 7);
	} else if (deltaSecs < 60 * 60 * 24 * 7 * 4 * 12) {
		unit = "month";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24 / 7 / 4);
	} else {
		unit = "year";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24 / 7 / 4 / 12);
	}
	const formatter = new Intl.RelativeTimeFormat("en", { style: "long", numeric: "auto" });
	return formatter.format(-delta, unit);
}

//──────────────────────────────────────────────────────────────────────────────

/** @typedef {object} NyaaapiResponse
 * @property {string} category
 * @property {string} title
 * @property {string} link
 * @property {string} torrent
 * @property {string} magnet
 * @property {string} size
 * @property {string} time
 * @property {number} seeders
 * @property {number} leechers
 * @property {number} downloads
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];

	// DOCS https://github.com/Vivek-Kolhe/Nyaa-API
	const apiURL = "https://nyaaapi.onrender.com/nyaa?category=anime&q=" + encodeURIComponent(query);
	const response = JSON.parse(httpRequest(apiURL));

	/** @type {AlfredItem[]} */
	const items = response.data.map((/** @type {NyaaapiResponse} */ item) => {
		const { title, category, link, magnet, seeders, leechers, time, size } = item;

		// FIX since the API documentation does not specify how to filter for
		// sub-categories, we have to remove them manually
		if (category !== "Anime - English-translated") return {};

		const subtitle = [
			seeders + "↑",
			leechers + "↓",
			size, // GiB
			"(" + relativeDate(time) + ")",
		].join("   ");

		const cleanTitle = title
			.replace(/\.mkv$/, "") // extension
			.replace(/ ?\[[0-9A-F]+\]$/, ""); // hashes

		/** @type {AlfredItem} */
		const alfredItem = {
			title: cleanTitle,
			subtitle: subtitle,
			arg: magnet,
			quicklookurl: link,
		};
		return alfredItem;
	});

	return JSON.stringify({ items: items });
}
