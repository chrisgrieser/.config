#!/usr/bin/env osascript -l JavaScript

function run (argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
	const onlineJSON = (url) => JSON.parse (app.doShellScript(`curl -sL '${url}'`));

	//------------------------------------------------------------------------------
	const query = argv.join("");
	const baseURI =
	const resultsJSON = onlineJSON("https://developer.mozilla.org/api/v1/search?q=" + query)
		.documents
		.map(item => {

			return {
				"title": item,
				"match": alfredMatcher (item),
				"subtitle": item,
				"arg": item,
			};
		});

	return JSON.stringify({ items: resultsJSON });
}
