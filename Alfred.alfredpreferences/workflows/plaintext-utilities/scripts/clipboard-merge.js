#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const clipbHistory = [];
	for (let i = 0; i <= 20; i++) {
		clipbHistory[i] = $.getenv(`cb${i}`);
	}

}

scri
