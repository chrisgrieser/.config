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

/** @typedef {Object} rAnimeRanking
 * @property {string} title
 * @property {string} title_english
 * @property {string} url // reddit url
 * @property {number} karma
 * @property {number} karma_change
 * @property {number} rank_change
 * @property {number} mal_id
 * @property {number} episode
 * @property {number} comments
 * @property {{large: string, medium: string}?} images
 * @property {{name: string, url: string, logo: string}?} streams
 */

//──────────────────────────────────────────────────────────────────────────────

// SOURCE https://github.com/abysswatcherbel/abysswatcherbel.github.io
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const useJapTitle = $.getenv("seasonal_jap_title");

	const baseURL =
		"https://raw.githubusercontent.com/abysswatcherbel/abysswatcherbel.github.io/refs/heads/main/static/data/";
	const weeklyURL = baseURL + "2025/spring/week_3.json";

	const response = JSON.parse(httpRequest(weeklyURL));
	/** @type {AlfredItem[]} */
	const items = response.map((/** @type {rAnimeRanking} */ show) => {
		const subtitle = [
			"E" + show.episode.toString().padEnd(2, " "),
			"🔼 " + show.karma,
			"💬 " + show.comments,
			"",
			`(${show.rank_change > 0 ? "+" : "-"}${show.rank_change})`,
		].join("   ");

		/** @type {AlfredItem} */
		const alfredItem = {
			title: useJapTitle ? show.title : show.title_english,
			subtitle: subtitle,
			arg: show.url, // reddit URL
			mods: {
				cmd: {
					arg: show.mal_id,
					subtitle: "⌘: Open at " + $.getenv("open_at"),
					valid: Boolean(show.mal_id),
				},
				shift: {
					arg: show.streams?.url,
					subtitle: show.streams?.url
						? "⇧: Open at " + show.streams?.name
						: "⇧: No stream available",
					valid: Boolean(show.streams?.url),
				},
			},
			quicklookurl: show.images?.large || show.images?.medium,
		};
		return alfredItem;
	});

	return JSON.stringify({ items: items });
}
