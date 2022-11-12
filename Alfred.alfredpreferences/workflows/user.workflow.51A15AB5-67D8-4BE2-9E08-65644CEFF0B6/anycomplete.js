#!/usr/bin/env osascript -l JavaScript
function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	// function alfredMatcher(str) {
	// 	const clean = str.replace(/-/g, " ");
	// 	return [clean, str].join(" ");
	// }

	const onlineJSON = (url) => JSON.parse(app.doShellScript(`curl -s "${url}"`));

	//──────────────────────────────────────────────────────────────────────────────

	const baseURL = "https://duckduckgo.com/ac/?q=";
	const query = argv.join("");

	//──────────────────────────────────────────────────────────────────────────────

	const jsonArray = onlineJSON(baseURL + query)
		.map(item => {
			const completion = item.phrase;
			return {
				"title": completion,
				"match": completion,
				"arg": completion,
			};
		});

	return JSON.stringify({ items: jsonArray });
}
