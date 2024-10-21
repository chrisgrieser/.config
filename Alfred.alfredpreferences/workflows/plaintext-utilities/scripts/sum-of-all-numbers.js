#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const selection = argv[0];

	const allDigits = selection.match(/-?[0-9]+/g) || [];
	const sum = allDigits.map(Number.parseFloat).reduce((a, b) => a + b, 0);

	return sum.toString();
}
