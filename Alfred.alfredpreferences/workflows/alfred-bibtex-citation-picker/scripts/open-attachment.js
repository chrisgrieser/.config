#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

const openFile = (/** @type {string} */ path) => Application("Finder").open(Path(path));

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	let path = argv[0];

	// GUARD invalid URIs https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Errors/Malformed_URI
	// see also https://github.com/chrisgrieser/alfred-bibtex-citation-picker/issues/64
	try {
		path = decodeURIComponent(path);
	} catch (_error) {
		console.log(`Malformed path : ${path}`);
	}
	path = path
		.replace(/;\/Users\/.*/, "") // multiple attachments https://github.com/chrisgrieser/alfred-bibtex-citation-picker/issues/45
		.replace(/^file:\/\//, "")
		.replace(/^~/, app.pathTo("home folder")); // expand ~

	console.log("🪚 path:", path);
	app.openLocation(path);
}
