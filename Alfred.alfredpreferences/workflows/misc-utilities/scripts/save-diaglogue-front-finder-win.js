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
		const finderSel = decodeURIComponent(Application("Finder").selection()[0].url().slice(7));
		app.setTheClipboardTo(finderSel);

		se.keystroke("g", { using: ["command down", "shift down"] });
		delay(0.2);

		se.keystroke("v", { using: ["command down"] });
		se.keyCode(36); // return-key
	} catch (_error) {
		return "No Finder window open.";
	}
}
