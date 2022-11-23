#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	const url = "https://www.inoreader.com/search/feeds/" + encodeURIComponent(argv[0]);
	app.openLocation(url);
}


//──────────────────────────────────────────────────────────────────────────────
