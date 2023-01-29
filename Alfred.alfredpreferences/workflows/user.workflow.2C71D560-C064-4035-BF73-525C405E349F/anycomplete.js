#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	//──────────────────────────────────────────────────────────────────────────────

	const baseURL = "https://duckduckgo.com/ac/?q=";
	const query = argv.join("");

	const jsonArray = JSON.parse(app.doShellScript(`curl -s "${baseURL}${query}"`))
		.map(item => {
			return {
				"title": item.phrase,
				"arg": item.phrase,
			};
		});

	return JSON.stringify({ items: jsonArray });
}
