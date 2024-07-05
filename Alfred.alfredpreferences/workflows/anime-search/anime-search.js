#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	const requestStr = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
	return requestStr;
}

/** @param {string} title */
function shortenSeason(title) {
	if (!title) return "";
	return title.replace(/ Season (\d+)$/, " S$1");
}

/** @typedef {Object} MalEntry
 * @property {number} mal_id
 * @property {string} title
 * @property {string} title_english
 * @property {string} url
 * @property {string} status
 * @property {string[]} title_synonyms
 * @property {number} year
 * @property {number} score
 * @property {number} episodes
 * @property {{name: string}[]} genres
 * @property {{name: string}[]} themes
 * @property {{name: string}[]} demographics
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	// GUARD
	if (!query) {
		return JSON.stringify({
			items: [{ title: "Search for an anime", subtitle: "Enter name of anime…" }],
		});
	}

	// INFO rate limit: 60 requests/minute https://docs.api.jikan.moe/#section/Information/Rate-Limiting
	// DOCS https://docs.api.jikan.moe/#tag/anime/operation/getAnimeSearch
	const resultsNumber = 9; // Alfred display maximum
	const apiURL = `https://api.jikan.moe/v4/anime?limit=${resultsNumber}&q=`;
	const response = JSON.parse(httpRequest(apiURL + encodeURIComponent(query)));
	if (!response.data) {
		// biome-ignore lint/suspicious/noConsoleLog: intentional
		console.log(JSON.stringify(response));
		return JSON.stringify({ items: [{ title: "ERROR. See debugging log." }] });
	}
	if (response.data.length === 0) {
		return JSON.stringify({ items: [{ title: "No results found." }] });
	}

	/** @type AlfredItem[] */
	const animeTitles = response.data.map((/** @type {MalEntry} */ anime) => {
		// biome-ignore format: annoyingly long list
		const { title, title_english, title_synonyms, year, status, episodes, score, genres, themes, demographics, url } = anime;

		const titleEng = shortenSeason(title_english || title);
		const yearInfo = year && !titleEng.match(/\d{4}/) ? `(${year})` : "";

		let emoji = "";
		if (status === "Currently Airing") emoji += "🎙️";
		else if (status === "Not yet aired") emoji += "🗓️";

		const displayText = [emoji, titleEng, yearInfo].filter(Boolean).join(" ");

		const titleJapMax = 40; // CONFIG
		let titleJap = shortenSeason(title_english ? title : title_synonyms[0]);
		if (titleJap === titleEng) titleJap = ""; // skip identical titles
		titleJap =
			"🇯🇵 " + (titleJap.length > titleJapMax ? titleJap.slice(0, titleJapMax) + "…" : titleJap);

		const episodesStr = episodes && "📺 " + episodes.toString();
		const scoreStr = score && "⭐ " + score.toFixed(1).toString();

		const genreInfo =
			"[" + [...demographics, ...genres, ...themes].map((genre) => genre.name).join(", ") + "]";

		const subtitle = [episodesStr, scoreStr, titleJap, genreInfo]
			.filter((component) => (component || "").match(/\w/)) // not emojiy only
			.join("  ");

		return {
			title: displayText,
			subtitle: subtitle,
			arg: url,
			quicklookurl: url,
			mods: {
				cmd: { arg: titleJap, valid: Boolean(titleJap) },
			},
		};
	});
	return JSON.stringify({ items: animeTitles });
}
