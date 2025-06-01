#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const selection = argv[0];

	// Accepts negative numbers or floats with two digits (i.e., prices). works
	// with , or . as decimal separator. Does NOT work with thousand separators.
	const allDigits = selection.match(/-?\d+([,.]\d\d)?/g) || [];
	const sum = allDigits.map(Number.parseFloat).reduce((a, b) => a + b, 0);

	return sum.toString();
}
