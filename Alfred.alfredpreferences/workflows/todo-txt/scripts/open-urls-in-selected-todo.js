#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// get selected task via clipboard
	const se = Application("System Events");
	se.includeStandardAdditions = true;
	se.keystroke("c", { using: ["command down"] });
	delay(0.1); // wait for clipboard
	const clipb = se.theClipboard();

	// mark as completed
	se.keystroke("x");

	// search for URLs and open any
	const urls = clipb.match(
		/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)/g,
	);
	if (!urls) return;
	for (const url of urls) {
		app.openLocation(url);
	}
}
