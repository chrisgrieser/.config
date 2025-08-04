#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/** @param {string} langCode */
function langCodeToFlagEmoji(langCode) {
	// biome-ignore format: too long
	const /** @type {Record<string, string>} */ langToCountry = {
		en: "US", fr: "FR", de: "DE", es: "ES", it: "IT", pt: "PT", ru: "RU",
		ja: "JP", zh: "CN", ko: "KR", nl: "NL", sv: "SE", no: "NO", da: "DK",
		fi: "FI", pl: "PL", cs: "CZ", ar: "SA", he: "IL", tr: "TR", vi: "VN",
		th: "TH", uk: "UA", hi: "IN", id: "ID", ro: "RO", hu: "HU", bg: "BG",
		sr: "RS", hr: "HR", sk: "SK", el: "GR", lt: "LT", lv: "LV", et: "EE",
		fa: "IR",
	};

	const countryCode = langToCountry[langCode];
	if (!countryCode) return "🏳️"; // Unknown / neutral flag

	return (
		countryCode
			.toUpperCase()
			.split("")
			// biome-ignore lint/nursery/useNumericSeparators: faulty, does not apply to codepoint
			.map((c) => String.fromCodePoint(0x1f1e6 + c.charCodeAt(0) - 65))
			.join("")
	);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	if (!query) return;
	const encodedQuery = encodeURIComponent(query);

	const langCodes = $.getenv("language_code").split(/ *, */);
	const maxResults = Number($.getenv("results_per_language"));
	const useWikiwand = $.getenv("use_wikiwand") === "1";

	// DOCS Wikipedia Open Search API: https://www.mediawiki.org/wiki/API:Opensearch#JavaScript
	// TEST API Sandbox: https://en.wikipedia.org/wiki/Special:ApiSandbox#action=opensearch&format=json&search=Hampi&namespace=0&limit=10&formatversion=2

	/** @type AlfredItem[] */
	const wikiEntries = [];

	for (const lang of langCodes) {
		const apiCall = `https://${lang}.wikipedia.org/w/api.php?action=opensearch&format=json&search=${encodedQuery}&namespace=0&limit=${maxResults}&profile=fuzzy`;
		const wikiItems = JSON.parse(httpRequest(apiCall));

		for (let i = 0; i < wikiItems[1].length; i++) {
			const suggestion = wikiItems[1][i];
			const desc = wikiItems[2][i]; // often empty
			let url = wikiItems[3][i];

			if (useWikiwand)
				url = url.replace(/.*\/wiki\/(.+)/, `https://www.wikiwand.com/${lang}/$1`);

			// only show languages if actually more than one
			const langFlag = langCodes.length > 1 ? langCodeToFlagEmoji(lang) : "";

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

	return JSON.stringify({ items: wikiEntries });
}
