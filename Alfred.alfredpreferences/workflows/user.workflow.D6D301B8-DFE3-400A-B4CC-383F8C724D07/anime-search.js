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

function shortenSeason(title) {
	if (!title) return "";
	return title.replace(/ Season (\d+)$/, " S$1");
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	if (!query) {
		return JSON.stringify({
			items: [{ title: "Search for an anime", subtitle: "Enter the name of the anime" }],
		});
	}

	// DOCS https://docs.api.jikan.moe/#tag/anime/operation/getAnimeSearch
	const alfredDisplayLimit = 9;
	const apiURL = `https://api.jikan.moe/v4/anime?limit=${alfredDisplayLimit}&q=`;
	const response = JSON.parse(httpRequest(apiURL + encodeURIComponent(query)));
	if (!response.data) {
		console.log(JSON.stringify(response));
		return JSON.stringify({ items: [{ title: "ERROR. See Console" }] });
	}
	if (response.data.length === 0) {
		return JSON.stringify({ items: [{ title: "No results found" }] });
	}

	/** @type AlfredItem[] */
	const animeTitles = response.data.map((anime) => {
		const titleEng = shortenSeason(anime.title_english || anime.title)
		const yearInfo = anime.year && !titleEng.match(/\d{4}/) ? `(${anime.year})` : "";
		const airingIcon = anime.airing ? " 🎙️" : "";
		const displayText = [titleEng, yearInfo, airingIcon].filter(Boolean).join(" ");

		const titleJap = shortenSeason(anime.title_english ? anime.title : anime.title_synonyms[0])
		const episodesInfo = anime.episodes ? `${anime.episodes}●` : "";
		const score = anime.score ? `${anime.score.toFixed(1)}★` : "";
		const subtitle = [episodesInfo, score, titleJap].filter(Boolean).join("   ");

		return {
			title: displayText,
			subtitle: subtitle,
			arg: anime.url,
			mods: {
				cmd: {
					arg: titleJap,
					valid: Boolean(titleJap),
				},
				shift: {
					arg: anime.trailer?.url,
					valid: Boolean(anime.trailer?.url),
				},
			},
		};
	});
	return JSON.stringify({ items: animeTitles });
}
