#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//------------------------------------------------------------------------------

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (finder.exists(Path(cacheDir))) return;
	console.log("Cache directory does not exist and is created.");
	const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
	const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
	finder.make({
		new: "folder",
		at: Path(cacheDirParent),
		withProperties: { name: cacheDirBasename },
	});
}
const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//------------------------------------------------------------------------------

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const selection = argv[0];
	if (!selection) return "No selection."; // for Alfred notification

	// DOCS https://scryfall.com/docs/api/cards/named
	const apiUrl = "https://api.scryfall.com/cards/named?fuzzy=" + encodeURIComponent(selection);
	// not using c-bridge for http-request, since it fails on error-response
	const response = app.doShellScript(`curl --silent --location "${apiUrl}"`);
	if (!response) return "No response from Scryfall";
	const json = JSON.parse(response);
	if (json.object === "error") return json.details;

	/** @type {ScryfallCard} */
	const card = json;
	const isFlippable = card.card_faces;
	const cardSides = isFlippable ? [card.card_faces[0], card.card_faces[1]] : [card];

	let localCardImagePaths = "";
	ensureCacheFolderExists();
	for (let i = 0; i < cardSides.length; i++) {
		const side = cardSides[i];
		const imageUrl = side.image_uris?.png;
		if (!imageUrl) return "No image found for the card.";

		const localImagePath = $.getenv("alfred_workflow_cache") + `/${card.id}_${i}.png`;

		if (!fileExists(localImagePath)) {
			app.doShellScript(`curl --silent --location "${imageUrl}" --output "${localImagePath}"`);
		}
		localCardImagePaths += localImagePath + "\n"; // use `\n` as separator in Alfred later
	}
	return localCardImagePaths; // open via Alfred's image view
}
