#!/usr/bin/env osascript -l JavaScript

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const tot = Application("Tot");
	tot.includeStandardAdditions = true;

	// DOCS in theory, colors are customizable: https://support.iconfactory.com/kb/tot/can-i-customize-the-colors-of-the-dots
	const totColors = ["🟡", "🟠", "🔴", "🟣", "🔵", "⚪", "🟢"];

	let emptyCount = 0;
	const tots = [1, 2, 3, 4, 5, 6, 7].map((dot) => {
		// DOCS https://gist.github.com/chockenberry/d33ef5b6e6da4a3e4aa9b07b093d3c23
		const content = tot.openLocation(`tot://${dot}/content`);
		if (!content) {
			emptyCount++;
			return {};
		}
		const firstLine = content.split("\n")[0];
		const secondLine = content.split("\n")[1];
		return {
			title: totColors[dot - 1] + " " + firstLine,
			subtitle: secondLine,
			match: firstLine + " " + secondLine,
			arg: dot,
			mods: {
				alt: { arg: content },
				cmd: {
					arg: "",
					variables: { dot: dot }
				},
			},
		};
	});

	// guard: all tots empty
	if (emptyCount === 7) {
		return JSON.stringify({
			items: [{ title: "All tots empty.", valid: false }],
		});
	}

	return JSON.stringify({ items: tots });
}
