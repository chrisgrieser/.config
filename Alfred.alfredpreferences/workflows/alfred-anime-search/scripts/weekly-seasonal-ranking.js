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
 * @property {number} current_rank
 * @property {number|string} rank_change // string for "returning" and such
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
	const useJapTitle = $.getenv("seasonal_jap_title") === "1";

	// TODO get correct week
	const baseURL =
		"https://raw.githubusercontent.com/abysswatcherbel/abysswatcherbel.github.io/refs/heads/main/static/data/";
	const year = 2025;
	const season = "spring";
	const weekNum = 2;
	const weeklyURL = `${baseURL}${year}/${season}/week_${weekNum}.json`;

	let totalKarma = 0;

	const response = JSON.parse(httpRequest(weeklyURL));
	/** @type {AlfredItem[]} */
	const items = response.map((/** @type {rAnimeRanking} */ show) => {
		totalKarma += show.karma; // NOTE side effect, buf simpler this way
		let rankChange = "";
		if (typeof show.rank_change === "number" && show.rank_change !== 0) {
			rankChange = (show.rank_change > 0 ? "📈" : "📉") + " " + show.rank_change.toString();
		} else if (show.rank_change === 0) {
			rankChange = "🟰";
		} else if (show.rank_change === "returning") {
			rankChange = "🔁";
		} else if (show.rank_change === "new") {
			rankChange = "🆕";
		}
		const karmaChange = show.karma_change ? ` (${show.karma_change})` : "";

		const ranking = (show.current_rank + ")").padEnd(3, " ");
		const title = useJapTitle ? show.title : show.title_english;

		const subtitle = [
			"E" + show.episode.toString().padEnd(2, " "),
			"🔼 " + show.karma + karmaChange,
			"💬 " + show.comments,
			rankChange,
		].join("    ");

		/** @type {AlfredItem} */
		const alfredItem = {
			title: ranking + " " + title,
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

	// add info as first item
	const seasonCapitalized = season.charAt(0).toUpperCase() + season.slice(1);
	const totalKarmaInfo = "Total karma: " + totalKarma.toLocaleString();
	items.unshift({
		title: `r/anime: ${seasonCapitalized} ${year}, week #${weekNum}`,
		subtitle: totalKarmaInfo,
		valid: false,
		mods: {
			shift: { subtitle: totalKarmaInfo, valid: false },
			cmd: { subtitle: totalKarmaInfo, valid: false },
		},
	});

	return JSON.stringify({
		items: items,
		skipknowledge: true, // keep ranking order
		cache: {
			seconds: 3600 * 3, // 3 hours
			loosereload: true,
		},
	});
}
