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
	console.log("🪚 apiURL:", apiURL);
	const response = JSON.parse(httpRequest(apiURL));
	console.log("🪚 response:", JSON.stringify(response, null, 2))

	/** @type {AlfredItem[]} */
	const items = response.data.map((/** @type {NyaaapiResponse} */ item) => {
		const { title, category, link, magnet, seeders, leechers, time, size } = item;

		// FIX since the API documentation does not specify how to filter for
		// sub-categories, we have to remove them manually
		if (category !== "Anime - English-translated") return {};

		const subtitle = [
			seeders + "⬆️",
			leechers + "↓",
			size,
			time,
		].join(" · ");

		/** @type {AlfredItem} */
		const alfredItem = {
			title: title,
			subtitle: subtitle,
			arg: magnet,
			quicklookurl: link,
		};
		return alfredItem;
	});

	return JSON.stringify({ items: items });
}
