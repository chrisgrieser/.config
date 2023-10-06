#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const tot = Application("Tot");
	tot.includeStandardAdditions = true;

	// DOCS colors are customizable: https://support.iconfactory.com/kb/tot/can-i-customize-the-colors-of-the-dots
	const totIcons = $.getenv("tot_icons").split(/, ?/);

	const showAll = $.getenv("alfred_workflow_keyword") === $.getenv("show_all_keyword");
	let emptyCount = 0;

	/** @type {AlfredItem[]} */
	const tots = [1, 2, 3, 4, 5, 6, 7].map((dot) => {
		// DOCS https://gist.github.com/chockenberry/d33ef5b6e6da4a3e4aa9b07b093d3c23
		const content = tot.openLocation(`tot://${dot}/content`);
		const emptyTot = content === "";
		if (emptyTot && !showAll) {
			emptyCount++;
			return {};
		}
		const firstLine = content.split("\n")[0];
		const secondLine = content.split("\n")[1];
		const icon = totIcons[dot - 1] || " · ";

		/** @type {AlfredItem} */
		const item = {
			title: icon + " " + firstLine,
			subtitle: secondLine,
			match: firstLine + " " + secondLine,
			arg: dot.toString(),
			mods: {
				ctrl: { valid: !emptyTot }, // delete
				alt: { arg: content, valid: !emptyTot }, // copy
				cmd: { arg: "", variables: { dot: dot } }, // append
			},
		};
		return item;
	});

	// guard: all tots are empty
	if (emptyCount === 7) {
		/** @type {AlfredItem[]} */
		tots.push({ title: totIcons[0] + " New Tot", arg: "" });
	}

	return JSON.stringify({
		items: tots,
		rerun: 0.1, // so switching keywords works
	});
}
