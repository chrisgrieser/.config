#!/usr/bin/env osascript -l JavaScript
// DOCS https://gist.github.com/chockenberry/d33ef5b6e6da4a3e4aa9b07b093d3c23

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const tot = Application("Tot");
	tot.includeStandardAdditions = true;

	const totColors = [ "🟡", "🟠", "🔴", "🟢", "🟣", "🔵", "🟤" ]

	const tots = [1, 2, 3, 4, 5, 6, 7].map((dot) => {
		const content = tot.openLocation(`tot://${dot}/content`);
		const firstLine = content.split("\n")[0];
		const secondLine = content.split("\n")[1];
		return {
			title: totColors[dot - 1] + " " + firstLine,
			subtitle: secondLine,
			arg: dot,
			match: firstLine + " " + secondLine,
		};
	});

	return JSON.stringify({ items: tots });
}
