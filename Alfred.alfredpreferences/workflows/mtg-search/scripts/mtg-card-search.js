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
 * @property {string} set abbreviation
 * @property {string} set_name full name
 * @property {"common"|"uncommon"|"rare"|"mythic"} rarity
 * @property {("U"|"W"|"B"|"R"|"G")[]?} colors
 * @property {{cardmarket: string, tcgplayer: string}} purchase_uris
 * @property {{usd: string, eur: string}?} prices
 * @property {{small: string, normal: string, large: string, png: string}?} image_uris
 * @property {number?} power
 * @property {number?} toughness
 * @property {("paper"|"mtgo"|"arena")[]} games
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {Record<string, string>} */
const manaEmojiMap = {
	"{U}": "🔵",
	"{W}": "🟡",
	"{B}": "⚫",
	"{R}": "🔴",
	"{G}": "🟢",
	"{C}": "💠", // colorless -> diamond mana
	"{X}": "✖",
	"{1}": "1️⃣",
	"{2}": "2️⃣",
	"{3}": "3️⃣",
	"{4}": "4️⃣",
	"{5}": "5️⃣",
	"{6}": "6️⃣",
	"{7}": "7️⃣",
	"{8}": "8️⃣",
	"{9}": "9️⃣",
	"{10}": "🔟",
};

const rarityEmojiMap = {
	common: "🥉",
	uncommon: "🥈",
	rare: "🥇",
	mythic: "🔸",
};

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
	const market = /** @type {"cardmarket"|"tcgplayer"} */ ($.getenv("market"));
	const onlyPaper = $.getenv("only_paper") === "1";

	// DOCS https://scryfall.com/docs/api/cards/search
	const apiUrl =
		"https://api.scryfall.com/cards/search?order=released&q=" + encodeURIComponent(query);
	const response = httpRequest(apiUrl);
	if (!response) return errorItem("No response from Scryfall", "Try again later");
	const cardData = JSON.parse(response).data;
	if (cardData.length === 0) return errorItem("No cards found.");

	/** @type {AlfredItem[]} */
	const items = cardData.flatMap((/** @type {ScryfallCard} */ card) => {
		if (onlyPaper && !card.games.includes("paper")) return [];

		let icon = card.colors?.[0] || "colorless";
		if (card.colors && card.colors.length > 1) icon = "multi";
		if (card.type_line.includes("Land")) icon = "land";

		const purchaseUrl = card.purchase_uris?.[market];
		const eurPrice = card.prices?.eur ? card.prices.eur + " €" : "";
		const usdPrice = card.prices?.usd ? "$" + card.prices.usd : "";
		const displayPrice = market === "cardmarket" ? eurPrice : usdPrice;
		const imageUrl = card.image_uris?.png;
		const manaCost = card.mana_cost?.replace(/\{\w+\}/g, (cost) => manaEmojiMap[cost] || cost);
		const yearOfRelease = card.released_at.slice(0, 4);
		const rarity = rarityEmojiMap[card.rarity] || card.rarity;
		const combatStats = card.power && card.toughness ? `${card.power}/${card.toughness}` : "";
		const type = [combatStats, card.type_line].filter(Boolean).join(" ");
		const set = card.set.toUpperCase();

		const subtitle = [manaCost, type, displayPrice, `${rarity} ${set} ${yearOfRelease}`]
			.filter(Boolean)
			.join("      ");

		return {
			title: card.name,
			subtitle: subtitle,
			icon: { path: `./mana-symbols/${icon}.png` },
			arg: card.scryfall_uri,
			quicklookurl: imageUrl,
			mods: {
				cmd: { arg: purchaseUrl },
				opt: { arg: card.scryfall_uri }, // copy scryfall url
				ctrl: {
					// copy card image
					arg: imageUrl,
					valid: Boolean(imageUrl),
					subtitle: imageUrl ? "⌃: Copy card image" : "⛔ Card image not available",
				},
			},
		};
	});

	return JSON.stringify({ items: items });
}
