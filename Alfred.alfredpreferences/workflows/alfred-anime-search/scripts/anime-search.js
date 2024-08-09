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
 * @param {{title: string, type: string}[]} titles
 * @param {string} type
 * @param {string} fallbackType
 * @return {string}
 */
function getTitle(titles, type, fallbackType) {
	const foundTitle =
		titles.find((t) => t.type === type) || titles.find((t) => t.type === fallbackType);
	return foundTitle?.title.replace(/ Season (\d+)$/, " S$1") || "";
}

/** @param {string} title @param {string} subtitle */
function errorItem(title, subtitle) {
	return JSON.stringify({ items: [{ title: title, subtitle: subtitle, valid: false }] });
}

// INFO streaming info not available via search API https://github.com/jikan-me/jikan-rest/issues/529
// PERF not doing a separate call for performance reasons
/** @typedef {Object} MalEntry
 * @property {number} mal_id
 * @property {{title: string, type: string}[]} titles
 * @property {string} url
 * @property {string} status
 * @property {number} year
 * @property {number} score
 * @property {number} episodes
 * @property {{name: string}[]} genres
 * @property {{name: string}[]} themes
 * @property {{name: string}[]} demographics
 * @property {{jpg: {large_image_url: string}, webp: {large_image_url: string}}} images
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// GUARD
	const query = argv[0];
	if (!query) return errorItem("Search for anime", "Enter name of anime…");

	// PARAMETERS
	const altSearchJap = $.getenv("alt_search_jap") === "1";
	const resultsNumber = 9; // alfred display maximum
	const [_, altSearchHostname] =
		$.getenv("alt_search_url").match(/https?:\/\/(?:www\.)?(\w+\.\w+)/) || [];

	// API REQUEST
	// INFO rate limit: 60 requests/minute https://docs.api.jikan.moe/#section/Information/Rate-Limiting
	// DOCS https://docs.api.jikan.moe/#tag/anime/operation/getAnimeSearch
	const apiURL = `https://api.jikan.moe/v4/anime?limit=${resultsNumber}&q=`;
	const response = JSON.parse(httpRequest(apiURL + encodeURIComponent(query)));
	if (!response.data) {
		// biome-ignore lint/suspicious/noConsoleLog: intentional
		console.log(JSON.stringify(response));
		return errorItem("Unknown Error", "See debugging log.");
	}
	if (response.data.length === 0) return errorItem("No Results", "");

	//───────────────────────────────────────────────────────────────────────────

	/** @type AlfredItem[] */
	const animeTitles = response.data.map((/** @type {MalEntry} */ anime) => {
		// biome-ignore format: annoyingly long list
		const { titles, mal_id, year, status, episodes, score, genres, themes, demographics, images } = anime;

		// TITLE
		const titleEng = getTitle(titles, "English", "Default");
		const yearInfo = year && !titleEng.match(/\d{4}/) ? `(${year})` : "";
		let emoji = "";
		if (status === "Currently Airing") emoji += "🎙️";
		else if (status === "Not yet aired") emoji += "🗓️";
		const displayText = [emoji, titleEng, yearInfo].filter(Boolean).join(" ");

		// SUBTITLE
		const titleJapMax = 40; // CONFIG
		let titleJap = getTitle(titles, "Default", "Synonym"); // default is romaji title
		if (titleJap === titleEng) titleJap = ""; // skip identical titles
		const titleJapDisplay =
			"🇯🇵 " + (titleJap.length > titleJapMax ? titleJap.slice(0, titleJapMax) + "…" : titleJap);
		const episodesStr = episodes && "📺 " + episodes.toString();
		const scoreStr = score && "⭐ " + score.toFixed(1).toString();
		const genreInfo =
			"[" + [...demographics, ...genres, ...themes].map((genre) => genre.name).join(", ") + "]";
		const subtitle = [episodesStr, scoreStr, titleJapDisplay, genreInfo]
			.filter((component) => (component || "").match(/\w/)) // not emojiy only
			.join("  ");

		// ALT SEARCH & QUICKLOOK
		const altSearchTitle = altSearchJap ? titleJap : titleEng;
		const altSearchSubtitle = `⇧: Search for "${altSearchTitle}" at ${altSearchHostname}`;
		const altSearchURL = $.getenv("alt_search_url") + encodeURIComponent(altSearchTitle);
		const image = images.webp.large_image_url || images.jpg.large_image_url;

		return {
			title: displayText,
			subtitle: subtitle,
			arg: mal_id, // will get URL from it
			quicklookurl: image,
			variables: { action: "open" },
			mods: {
				alt: {
					arg: mal_id, // will get URL from it
					variables: { action: "copy" },
				},
				cmd: {
					arg: titleJap,
					valid: Boolean(titleJap),
					variables: { action: "copy" },
				},
				shift: {
					arg: altSearchURL,
					subtitle: altSearchSubtitle,
					variables: { action: "open" },
				},
			},
		};
	});
	return JSON.stringify({ items: animeTitles });
}
