#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const mdImageLink = argv[0];
	const htmlImg = mdImageLink
		.replace(/!\[(.*?)\]\((.*?)\)/g, '<img alt="$1" width=70% src="$2">')
		.replace('alt="Image"', 'alt="Showcase"');
	return htmlImg;
}
