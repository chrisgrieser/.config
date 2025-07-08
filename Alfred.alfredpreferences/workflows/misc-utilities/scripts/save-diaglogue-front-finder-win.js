#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const se = Application("System Events");

	try {
		const selection = Application("Finder").selection()[0];
		const frontWin = Application("Finder").insertionLocation();
		const path = decodeURIComponent((selection || frontWin).url().slice(7));
		app.setTheClipboardTo(path);

		se.keystroke("g", { using: ["command down", "shift down"] });
		delay(0.2);

		se.keystroke("v", { using: ["command down"] });
		delay(0.1);
		se.keyCode(36); // return-key
	} catch (_error) {
		return "No Finder window open or no selection.";
	}
}
