#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const finder = Application("Finder");
	const se = Application("System Events");

	try {
		const finderWin = decodeURIComponent(finder.insertionLocation().url().slice(7));
		app.setTheClipboardTo(finderWin);

		se.keystroke("g", { using: ["command down", "shift down"] });
		delay(0.2);

		se.keystroke("v", { using: ["command down"] });
		se.keyCode(36); // return-key
	} catch (_error) {
		return "No Finder window open.";
	}
}
