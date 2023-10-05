#!/usr/bin/env osascript -l JavaScript

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const dot = argv[0];
	const tot = Application("Tot");
	tot.includeStandardAdditions = true;
	tot.openLocation(`tot://${dot}/replace?text=`);
}
