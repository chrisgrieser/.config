#!/usr/bin/env osascript -l JavaScript

function run (argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
	const onlineJSON = (url) => JSON.parse (app.doShellScript(`curl -sL '${url}'`));

	//------------------------------------------------------------------------------

	const query = argv.join("");
	const baseURL = "https://developer.mozilla.org";
	const searchAPI = "https://developer.mozilla.org/api/v1/search?q=";

	const resultsArr = onlineJSON(searchAPI + query).documents;
	let output = [];

	if (resultsArr.length === 0) {
		output = [{
			"title": "No documents found.",
			"valid": false,
			"arg": "no"
		}];
	} else {
		output = resultsArr.map(item => {
			const url = baseURL + item.mdn_url;
			return {
				"title": item.title,
				"match": alfredMatcher(item.title),
				"subtitle": item.summary,
				"arg": url,
			};
		});
	}

	return JSON.stringify({ items: output });
}
