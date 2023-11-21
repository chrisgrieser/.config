#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const tot = Application("Tot");
	tot.includeStandardAdditions = true;

	const dot = $.getenv("dot");
	const appendPrefix = $.getenv("append_prefix");
	const text = appendPrefix + argv[0];

	const empty = tot.openLocation(`tot://${dot}/content`).match(/^\s*$/);
	if (empty) {
		text.trim(); 
		tot.openLocation(`tots://${dot}/replace?text=${encodeURIComponent(text)}`);
	} else {
		tot.openLocation(`tots://${dot}/append?text=${encodeURIComponent(text)}`);
	} 

	// hide the app
	const totProcess = Application("System Events").applicationProcesses.byName("Tot");
	totProcess.visible = false

	// Pass for Alfred notification
	return text;
}
