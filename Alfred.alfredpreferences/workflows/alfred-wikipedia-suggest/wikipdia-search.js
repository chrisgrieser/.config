#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/** @type {Record<string, string>} */
// biome-ignore format: too long
const langToFlag = {
	en: "🇺🇸", fr: "🇫🇷", de: "🇩🇪", es: "🇪🇸", it: "🇮🇹", pt: "🇵🇹", ru: "🇷🇺", ja: "🇯🇵",
	zh: "🇨🇳", ko: "🇰🇷", nl: "🇳🇱", sv: "🇸🇪", no: "🇳🇴", da: "🇩🇰", fi: "🇫🇮", pl: "🇵🇱",
	cs: "🇨🇿", ar: "🇸🇦", he: "🇮🇱", tr: "🇹🇷", vi: "🇻🇳", th: "🇹🇭", uk: "🇺🇦", hi: "🇮🇳",
	id: "🇮🇩", ro: "🇷🇴", hu: "🇭🇺", bg: "🇧🇬", sr: "🇷🇸", hr: "🇭🇷", sk: "🇸🇰", el: "🇬🇷",
	lt: "🇱🇹", lv: "🇱🇻", et: "🇪🇪", fa: "🇮🇷",
};

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	if (!query) return;
	const encodedQuery = encodeURIComponent(query);

	const langCodes = $.getenv("language_code").split(/ *, */);
	const maxResults = Number($.getenv("results_per_language"));
	const wikiwand = $.getenv("use_wikiwand") === "1";

	// DOCS Wikipedia Open Search API: https://www.mediawiki.org/wiki/API:Opensearch#JavaScript
	// TEST API Sandbox: https://en.wikipedia.org/wiki/Special:ApiSandbox#action=opensearch&format=json&search=Hampi&namespace=0&limit=10&formatversion=2

	/** @type AlfredItem[] */ const wikiEntries = [];
	/** @type AlfredItem[] */ const errorEntries = [];

	for (const lang of langCodes) {
		const apiCall = `https://${lang}.wikipedia.org/w/api.php?action=opensearch&format=json&search=${encodedQuery}&namespace=0&limit=${maxResults}&profile=fuzzy`;
		const response = httpRequest(apiCall);

		let wikiItems = [];
		try {
			wikiItems = JSON.parse(response);
		} catch (_error) {
			console.log("error parsing response:", response);
			errorEntries.push({ title: "Error", subtitle: response });
			continue;
		}

		for (let i = 0; i < wikiItems[1].length; i++) {
			const suggestion = wikiItems[1][i];
			const desc = wikiItems[2][i]; // often empty
			let url = wikiItems[3][i];

			if (wikiwand) url = url.replace(/.*\/wiki\/(.+)/, `https://www.wikiwand.com/${lang}/$1`);

			// only show languages if actually more than one
			const langFlag = langCodes.length > 1 ? langToFlag[lang] || `[${lang}]` : "";

			wikiEntries.push({
				title: suggestion,
				subtitle: langFlag + " " + desc,
				quicklookurl: url, // used by AlfredExtraPane
				arg: url,
			});
		}
	}

	// if more than one language, sort by length of title, to prevent the entries
	// of the 2nd being displayed at the bottom
	if (langCodes.length > 1) wikiEntries.sort((a, b) => a.title.length - b.title.length);

	return JSON.stringify({ items: [...errorEntries, ...wikiEntries] });
}
