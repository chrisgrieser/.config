#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// DOCS https://support.busymac.com/help/70621-url-handler#creating-events-in-busycal

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const input = argv[0];

	// not working with Alfred's `Open URL` action, thus doing it here
	app.openLocation("busycalevent://new/" + encodeURIComponent(input));
}
