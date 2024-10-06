#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const today = new Date();
	const cal = Application("Calendar")
	const tomorrow = new Date();
	tomorrow.setDate(today.getDate() + 1);
}
