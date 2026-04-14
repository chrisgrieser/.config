#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//------------------------------------------------------------------------------

/** @typedef {Object} ScryfallCard
 * @property {string} id
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
 * @property {Record<string, "legal"|"not_legal"|"banned">} legalities
 * @property {boolean} gamechanger
 * @property {ScryfallCard[]} card_faces for flippable cards
 */

/** @type {Record<string, string>} */
const manaEmojiMap = {
	"{U}": "🔵",
	"{W}": "🟡", // yellow works on white background and is still associated with white mane
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
	const url = (title.match(/https?:\/\/\S+/) || (subtitle || "").match(/https?:\/\/\S+/))?.[0];
	return JSON.stringify({
		items: [
			{
				title: title,
				subtitle: subtitle || "",
				arg: url,
				valid: Boolean(url),
			},
		],
	});
}

//------------------------------------------------------------------------------

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	if (!query) return errorItem("Search for card…", "Supports Scryfall search syntax.");
	const market = /** @type {"cardmarket"|"tcgplayer"} */ ($.getenv("market"));
	const showOnlyPaper = $.getenv("only_paper") === "1";
	const illegalityFormat = $.getenv("illegality_format_1");

	// DOCS https://scryfall.com/docs/api/cards/search
	const apiUrl =
		"https://api.scryfall.com/cards/search?order=released&q=" + encodeURIComponent(query);
	// not using c-bridge for http-request, since it fails on error-response
	const response = app.doShellScript(`curl "${apiUrl}"`);
	if (!response) return errorItem("No response from Scryfall", "Try again later");
	const json = JSON.parse(response);
	if (json.object === "error") {
		console.log("⚠️ error object:", JSON.stringify(json, null, 2));
		let [_, title, subtitle] = json.details.match(/(^[^.]+\. )(.*)/) || ["", json.details, ""];
		if (json.warnings) subtitle += " " + json.warnings.join(" ");
		return errorItem(title.trim(), subtitle.trim());
	}

	const onlyOnlineCards = [];

	/** @type {AlfredItem[]} */
	const items = json.data.flatMap((/** @type {ScryfallCard} */ card) => {
		// for flippable cards use the front & add their properties to the main card
		// object, since properties are split across card and card face for them.
		const flippable = card.card_faces;
		if (flippable) card = { ...card, ...card.card_faces[0] };

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
		const notReleasedYet = new Date(card.released_at) > new Date();
		const futureIcon = notReleasedYet ? "🕒" : "";
		const rarity = rarityEmojiMap[card.rarity] || card.rarity;
		const combatStats = card.power && card.toughness ? `${card.power}/${card.toughness}` : "";
		const type = [combatStats, card.type_line].filter(Boolean).join(" ");
		const set = card.set.toUpperCase();
		const onlyOnline = !card.games.includes("paper");
		const onlyOnlineIcon = onlyOnline ? "🌐" : "";
		const legality =
			illegalityFormat === "none" || card.legalities[illegalityFormat] === "legal" ? "" : "⛔";
		const gameChanger = card.gamechanger ? "⭐" : "";
		const flipIcon = card.card_faces ? "🔄" : "";

		const subtitle = [manaCost, type, displayPrice, `${rarity} ${set} (${yearOfRelease})`]
			.filter(Boolean)
			.join("      ");
		const title = [
			gameChanger,
			card.name,
			flipIcon,
			onlyOnlineIcon,
			futureIcon || legality, // future cards are always illegal, thus replacing with future icon
		]
			.filter(Boolean)
			.join("  ");

		const alfredItem = {
			title: title,
			subtitle: subtitle,
			icon: { path: `./mana-symbols/${icon}.png` },
			arg: card.scryfall_uri,
			quicklookurl: imageUrl,
			variables: { cardname: card.name },
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

		if (showOnlyPaper && onlyOnline) {
			onlyOnlineCards.push(alfredItem);
			return [];
		}
		return alfredItem;
	});

	// items can only be 0 if the search resulted in online-only cards, because
	// scryfall already reports an error in that case
	if (items.length === 0) {
		onlyOnlineCards.unshift({
			title: "Only MTGO or MtG Arena cards found for this query.",
			subtitle: "They are displayed below.",
			valid: false,
		});
		return JSON.stringify({ items: onlyOnlineCards });
	}

	return JSON.stringify({ items: items });
}
