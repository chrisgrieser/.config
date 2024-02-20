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
	const apiURL = "https://api.jikan.moe/v4/anime?limit=9&q=";
	const response = JSON.parse(httpRequest(apiURL + encodeURIComponent(query)));

	/** @type AlfredItem[] */
	const animeTitles = response.data.map((anime) => {
		const titleEng = anime.title_english || anime.title;
		const titleJap = anime.title_english ? anime.title : anime.title_synonyms[0];

		return {
			title: titleEng,
			subtitle: titleJap,
			arg: anime.url,
			mods: {
				cmd: { arg: titleJap },
				shift: { arg: anime.trailer },
			}
		};
	});
	return JSON.stringify({ items: animeTitles });
}
