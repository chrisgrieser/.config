#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//------------------------------------------------------------------------------

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	if (1 !== 2) return "aa"
	const selection = argv[0];
	if (!selection) return "No selection."; // for Alfred notification

	// DOCS https://scryfall.com/docs/api/cards/named
	const apiUrl = "https://api.scryfall.com/cards/named?fuzzy=" + encodeURIComponent(selection);
	// not using c-bridge http-request, since it fails on error-response
	const response = app.doShellScript(`curl "${apiUrl}"`);
	if (!response) return "No response from Scryfall";
	const json = JSON.parse(response);
	if (json.object === "error") return json.details;

	const imageUrl = json.image_uris?.png;
	if (!imageUrl) return "No image found for the card.";

	app.doShellScript(`qlmanage -p "${imageUrl}"`);
}
