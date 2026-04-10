#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//------------------------------------------------------------------------------

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/** @typedef {Object} ScryfallCard
 * @property {string} name
 * @property {string} scryfall_uri
 * @property {string} released_at iso 8601 date
 * @property {string} mana_cost
 * @property {string} type_line instant, sorcery, etc
 * @property {string} oracle_text the card body
 * @property {"common"|"uncommon"|"rare"|"mythic"} rarity
 * @property {string[]} colors
 * @property {{cardmarket: string, tcgplayer: string}} purchase_uris
 * @property {{usd: string, eur: string}} prices
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];

	// DOCS https://scryfall.com/docs/api/cards/search
	const apiUrl = "https://api.scryfall.com/cards/search?q=" + encodeURIComponent(query);
	const response = httpRequest(apiUrl);
	if (!response) return JSON.stringify({ items: [{ title: "Error: No results", valid: false }] });

	const data = JSON.parse(response).data;
	if (!data.length) return JSON.stringify({ items: [{ title: "No cards found", valid: false }] });

	/** @type {AlfredItem[]} */
	const items = data.map((/** @type {{name: ScryfallCard}} */ card) => {
		return {
			title: card.name,
			subtitle: "",
			icon: { path: "scryfall-logo.png" },
			arg: card.name,
		};
	});

	return JSON.stringify({ items: items });
}
