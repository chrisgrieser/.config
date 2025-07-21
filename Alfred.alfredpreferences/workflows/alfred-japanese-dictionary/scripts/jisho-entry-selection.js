#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const readmoreIcon = "(…)";
const commonSymbol = "🅒"; // ᴄᴏᴍᴍᴏɴ, 🅲 ,🅒

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	const displayJlpt = $.getenv("display_jlpt") === "1";
	const displayWanikani = $.getenv("display_wanikani") === "1";
	const openAt = $.getenv("open_at");

	// DOCS the API is undocumented, but some info is delivered in this thread:
	// https://jisho.org/forum/54fefc1f6e73340b1f160000-is-there-any-kind-of-search-api
	// ALTERNATIVES (not as many suggestions though): https://jotoba.de/docs.html#post-/api/search/words
	const apiUrl = "https://jisho.org/api/v1/search/words?keyword=" + encodeURIComponent(query);

	/** @type {JishoResponse} */
	const response = JSON.parse(httpRequest(apiUrl));

	/** @type {AlfredItem[]} */
	const items = response.data
		// leave out dbpedia stuff, which only includes terms from wikipedia https://jisho.org/about
		.filter((item) => item.attribution.jmdict || item.attribution.jmnedict)
		.map((item) => {
			const { japanese, senses, is_common, jlpt, tags } = item;

			// basic
			const kanji = japanese[0].word;
			const kana = japanese[0].reading;
			const japWord = kanji || kana || "ERROR: Neither kanji nor kana found.";
			const japDisplay = kanji && kana ? `${kanji} 【${kana}】` : japWord;
			const engWord = senses.map((sense) => sense.english_definitions[0]).join(", ");
			const wordType = senses[0].parts_of_speech.join(", ");
			const url = openAt + japWord;
			const readMoreLink = senses.find((sense) => sense.links.length > 0)?.links[0];

			// properties
			const properties = [];
			if (is_common) properties.push(commonSymbol + " ");
			if (jlpt && displayJlpt) {
				const level = jlpt.map((j) => j.replace("jlpt-", "")).join(" ");
				properties.push(level);
			}
			if (tags && displayWanikani) {
				const level = tags.map((j) => j.replace("anikani", "")).join(" ");
				properties.push(level);
			}
			const propertiesDisplay = properties.join(" ").toUpperCase();

			// subtitle
			const subtitle = [
				engWord,
				wordType ? `[${wordType}]` : null,
				readMoreLink ? "  " + readmoreIcon : "",
			]
				.filter(Boolean)
				.join("    ");

			// csv
			const kebabWordType = wordType.toLowerCase().replaceAll(" ", "-").replaceAll(",-", " ");
			const csvLine = [kanji || "", kana || "", engWord, kebabWordType]
				.map((p) => '"' + p.replaceAll('"', '""') + '"') // quote, and escape double quotes
				.join(",");

			/** @type {AlfredItem} */
			const alfredItem = {
				title: japDisplay + "   " + propertiesDisplay,
				subtitle: subtitle,
				arg: japWord, // copy word
				quicklookurl: url,
				mods: {
					cmd: { arg: url }, // open dictionary url
					alt: { arg: url }, // copy dictionary url
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
