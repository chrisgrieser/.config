#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const tot = Application("Tot");
	tot.includeStandardAdditions = true;

	// DOCS in theory, colors are customizable: https://support.iconfactory.com/kb/tot/can-i-customize-the-colors-of-the-dots
	const totIcons = $.getenv("tot_icons").split(/, ?/);

	let emptyCount = 0;
	const tots = [1, 2, 3, 4, 5, 6, 7].map((dot) => {
		// DOCS https://gist.github.com/chockenberry/d33ef5b6e6da4a3e4aa9b07b093d3c23
		const content = tot.openLocation(`tot://${dot}/content`);
		if (!content) {
			emptyCount++;
			return {};
		}
		const firstLine = content.split("\n")[0].slice(0, 70);
		const secondLine = content.split("\n")[1].slice(0, 90);
		const icon = totIcons[dot - 1] || " · "
		return {
			title: icon + " " + firstLine,
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
		const dot = 1;
		return JSON.stringify({
			items: [{
				title: totIcons[dot - 1] + " New Tot",
				arg: "",
			}],
			variables: { dot: dot },
		});
	}

	return JSON.stringify({ items: tots });
}
