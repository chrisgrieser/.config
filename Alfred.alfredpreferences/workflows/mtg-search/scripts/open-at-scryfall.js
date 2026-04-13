#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//------------------------------------------------------------------------------

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const localImagePath = argv[0];

	// example: {path}/6904ea20-e504-47da-95a0-08739fdde260_0.png
	// (`_0` & `_1` were added to indicate card sides and are not part of the id)
	const scryfallId = localImagePath.match(/.*\/(.*)(_[01])\.png$/)?.[1];
	if (!scryfallId) return "No scryfall-id found in const path:" + localImagePath;

	// DOCS https://scryfall.com/docs/api/cards/id
	const apiUrl = `https://api.scryfall.com/cards/${scryfallId}`;
	// not using c-bridge for http-request, since it fails on error-response
	const response = app.doShellScript(`curl --silent --location "${apiUrl}"`);
	if (!response) return "No response from Scryfall";
	const json = JSON.parse(response);
	if (json.object === "error") return json.details;

	const url = json.scryfall_uri;
	app.openLocation(url);
}
