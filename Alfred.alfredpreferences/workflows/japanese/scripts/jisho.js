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

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	const displayJlpt = $.getenv("display_jlpt") === "1";
	const displayWanikani = $.getenv("display_wanikani") === "1";
	const openAt = $.getenv("open_at");
	const readmoreIcon = "  (...)";

	// DOCS the API is undocumented, but some info is delivered in this thread:
	// https://jisho.org/forum/54fefc1f6e73340b1f160000-is-there-any-kind-of-search-api
	// ALTERNATIVES (not as many suggestions though): https://jotoba.de/docs.html#post-/api/search/words
	const apiURL = "https://jisho.org/api/v1/search/words?keyword=" + encodeURIComponent(query);

	/** @type {JishoResponse} */
	const response = JSON.parse(httpRequest(apiURL));

	/** @type {AlfredItem[]} */
	const items = response.data.map((item) => {
		const { japanese, senses, is_common, jlpt, tags } = item;

		const kanji = japanese[0].word;
		const kana = japanese[0].reading;
		const japWord = kanji || kana || "ERROR: Neither kanji nor kana found.";
		const japDisplay = kanji && kana ? `${kanji} 【${kana}】` : japWord;
		const engWord = senses.map((sense) => sense.english_definitions[0]).join(", ");
		const url = openAt + japWord;
		const readMoreLink = senses.find((sense) => sense.links.length > 0)?.links[0];

		// properties
		const properties = [];
		if (jlpt && displayJlpt) {
			const level = jlpt.map((j) => j.replace("jlpt-", "")).join(" ");
			properties.push(level);
		}
		if (tags && displayWanikani) {
			const level = tags.map((j) => j.replace("anikani", "")).join(" ");
			properties.push(level);
		}
		const propertiesDisplay = properties.join(" ").toUpperCase();
		const csvLine = [engWord, kana || "", kanji || ""].join(";");

		/** @type {AlfredItem} */
		const alfredItem = {
			title: japDisplay + "   " + propertiesDisplay,
			icon: is_common ? { path: "./icon-common.png" } : {},
			subtitle: engWord + (readMoreLink ? " " + readmoreIcon : ""),
			arg: url,
			mods: {
				cmd: { arg: japWord }, // copy word
				alt: { arg: url }, // copy url
				ctrl: {
					valid: Boolean(readMoreLink),
					subtitle: readMoreLink ? "⌃: " + readMoreLink?.text : "",
					arg: readMoreLink?.url,
				},
				shift: { arg: japWord }, // play audio
				fn: { arg: csvLine, variables: { japWord: japWord, engWord: engWord } },
			},
		};
		return alfredItem;
	});

	return JSON.stringify({ items: items });
}
