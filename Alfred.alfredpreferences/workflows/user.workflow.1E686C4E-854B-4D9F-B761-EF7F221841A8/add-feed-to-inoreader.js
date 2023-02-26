#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	//───────────────────────────────────────────────────────────────────────────

	const url = argv[0];
	if (!url) {

	}


	const inoreaderURL = "https://www.inoreader.com/search/feeds/" + encodeURIComponent(url);
	app.openLocation(inoreaderURL);
}
