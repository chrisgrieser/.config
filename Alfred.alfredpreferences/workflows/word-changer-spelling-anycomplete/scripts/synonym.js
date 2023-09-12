#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	//───────────────────────────────────────────────────────────────────────────

	const baseURL = "https://api.datamuse.com/words?rel_syn=";
	const query = argv.join("");
	
	const jsonArray = JSON.parse(app.doShellScript(`curl -s '${baseURL}${query}'`))
		.map(item => {
			return {
				"title": item.word,
				"subtitle": item.score,
				"arg": item.word,
			};
		});

	return JSON.stringify({ items: jsonArray });
}
