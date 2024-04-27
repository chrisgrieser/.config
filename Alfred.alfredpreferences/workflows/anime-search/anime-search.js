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

	// DOCS https://docs.api.jikan.moe/#tag/anime/operation/getAnimeSearch
	const resultsNumber = 9; // Alfred display maximum
	const apiURL = `https://api.jikan.moe/v4/anime?limit=${resultsNumber}&q=`;
	const response = JSON.parse(httpRequest(apiURL + encodeURIComponent(query)));
	if (!response.data) {
		console.log(JSON.stringify(response));
		return JSON.stringify({ items: [{ title: "ERROR. See debugging log." }] });
	}
	if (response.data.length === 0) {
		return JSON.stringify({ items: [{ title: "No results found." }] });
	}

	/** @type AlfredItem[] */
	// @ts-expect-error
	const animeTitles = response.data.map((anime) => {
		// biome-ignore format: annoyingly long list
		let { title, title_english, title_synonyms, year, status, episodes, score, genres, themes, synopsis, url, studios, demographics } = anime;

		const titleEng = shortenSeason(title_english || title);
		const yearInfo = year && !titleEng.match(/\d{4}/) ? `(${year})` : "";

		let emoji = "";
		if (status === "Currently Airing") emoji += "🎙️";
		else if (status === "Not yet aired") emoji += "🗓️";

		const displayText = [emoji, titleEng, yearInfo].filter(Boolean).join(" ");

		const titleJapMax = 40; // CONFIG
		let titleJap = shortenSeason(title_english ? title : title_synonyms[0]);
		titleJap =
			"🇯🇵 " + (titleJap.length > titleJapMax ? titleJap.slice(0, titleJapMax) + "…" : titleJap);

		const episodesCount = "📺 " + episodes.toString();
		score = "⭐ " + score.toFixed(1).toString();
		genres = "📚 " + genres.map((/** @type {{ name: string }}*/ genre) => genre.name).join(", ");
		themes = "🎨 " + themes.map((/** @type {{ name: string }}*/ theme) => theme.name).join(", ");
		const studio = "🎦 " + studios[0].name.replace(/(studio|animation|production)s?/gi, "").trim();
		demographics = demographics.map((/** @type {{ name: string }}*/ demographic) => demographic.name).join(", ");

		const subtitle = [episodesCount, score, studio, titleJap, themes, genres]
			.filter((component) => component.match(/\w/)) // not emojiy only
			.join("  ");

		const summary = [genres, themes, studio, synopsis].filter(Boolean).join("\n");

		return {
			title: displayText,
			subtitle: subtitle,
			arg: url,
			quicklookurl: url,
			mods: {
				cmd: { arg: titleJap, valid: Boolean(titleJap) },
				shift: { arg: summary },
			},
		};
	});
	return JSON.stringify({ items: animeTitles });
}
