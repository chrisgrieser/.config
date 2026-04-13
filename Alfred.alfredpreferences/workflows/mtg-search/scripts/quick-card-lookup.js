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

	const imageUrl = json.image_uris?.normal;
	if (!imageUrl) return "No image found for the card.";

	ensureCacheFolderExists();
	const cacheLocation = $.getenv("alfred_workflow_cache") + "/quick-card-lookup.jpg";
	app.doShellScript(`curl --silent --location "${imageUrl}" --output "${cacheLocation}"`);
	return cacheLocation; // open via Alfred's image view
}
