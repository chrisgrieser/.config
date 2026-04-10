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
 * @property {("U"|"W"|"B"|"R"|"G")[]?} colors
 * @property {{cardmarket: string, tcgplayer: string}} purchase_uris
 * @property {{usd: string, eur: string}?} prices
 * @property {{small: string, normal: string, large: string, png: string}?} image_uris
 */

//──────────────────────────────────────────────────────────────────────────────

const colorMap = {
	// biome-ignore-start lint/style/useNamingConvention: not useful here
	U: "blue",
	W: "white",
	B: "black",
	R: "red",
	G: "green",
}; // biome-ignore-end lint/style/useNamingConvention: not useful here

/**
 * @param {string} title
 * @param {string?} [subtitle]
 */
function errorItem(title, subtitle) {
	return JSON.stringify({ items: [{ title: title, subtitle: subtitle || "", valid: false }] });
}

//------------------------------------------------------------------------------

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	if (!query) return errorItem("Search for card…", "Supports Scryfall search syntax.");

	// DOCS https://scryfall.com/docs/api/cards/search
	const apiUrl = "https://api.scryfall.com/cards/search?q=" + encodeURIComponent(query);
	const response = httpRequest(apiUrl);
	if (!response) return errorItem("No response from Scryfall", "Try again later");

	const cardData = JSON.parse(response).data;
	if (cardData.length === 0) return errorItem("No cards found.");

	/** @type {AlfredItem[]} */
	const items = cardData.map((/** @type {ScryfallCard} */ card) => {
		let color = card.colors?.[0] ? colorMap[card.colors[0]] : "colorless";
		if (card.colors && card.colors.length > 1) color = "multi";

		const purchaseUrl = card.purchase_uris?.cardmarket;
		const price = card.prices?.eur ? card.prices.eur + "€" : "";
		const image = card.image_uris?.png;
		const subtitle = [card.mana_cost, `${card.type_line}`, price].filter(Boolean).join("    ");

		return {
			title: card.name,
			subtitle: subtitle,
			icon: { path: `./mtg-icons/${color}.png` },
			arg: card.scryfall_uri,
			quicklookurl: image,
			mods: {
				cmd: { arg: purchaseUrl },
				opt: { arg: card.scryfall_uri }, // copy scryfall url
				ctrl: { arg: image }, // copy card image
			},
		};
	});

	return JSON.stringify({ items: items });
}
