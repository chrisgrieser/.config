#!/usr/bin/env osascript -l JavaScript

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const dot = argv[0];
	const tot = Application("Tot");
	tot.includeStandardAdditions = true;

	// delete content https://gist.github.com/chockenberry/d33ef5b6e6da4a3e4aa9b07b093d3c23
	tot.openLocation(`tot://${dot}/replace?text=`);

}
