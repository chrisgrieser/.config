#!/usr/bin/env osascript -l JavaScript

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// HACK reading urls via clipboard, since reading the current tot is not
	// supported yet https://pkm.social/@chockenberry@mastodon.social/111189109991083754

	// get the clipboard
	const se = Application("System Events");
	se.includeStandardAdditions = true;
	se.keystroke("a", { using: ["command down"] });
	se.keystroke("c", { using: ["command down"] });
	delay(0.05);
	se.keyCode(124); // arrow right -> deselect
	delay(0.05);
	const clipb = se.theClipboard();

	// search for URLs and open any
	const urls = clipb.match(
		/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/g,
	);
	if (!urls) return;
	for (const url of urls) {
		const app = Application.currentApplication()
		app.includeStandardAdditions = true;
		app.openLocation(url);
	}
}
