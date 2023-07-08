#!/usr/bin/env osascript -l JavaScript

function run (argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	const alfredMatcher = (str) => str.replace (/[-()_.:#]/g, " ")
		+ " " + str + " "
		+ str.replace(/([A-Z])/g, " $1"); // match parts of CamelCase
	const onlineJSON = (url) => JSON.parse (app.doShellScript(`curl -sL '${url}'`));

	//---------------------------------------------------------------------------

	const input = argv.join("").split(" ");
	const lang = input.shift();
	const query = input.join(" ");

	const baseURL = "https://developer.mozilla.org";
	const searchAPI = "https://developer.mozilla.org/api/v1/search?q=";
	const output = [];

	const resultsArr = onlineJSON(searchAPI + query)
		.documents
		.filter(result => result.mdn_url.includes(lang));

	if (resultsArr.length === 0) {
		output.push({
			"title": "No MDN documents found.",
			"subtitle": "MDN search sometimes requires longer queries before results are shown.",
			"valid": false,
			"arg": "no"
		});
	} else {
		resultsArr.forEach(item => {
			const url = baseURL + item.mdn_url;
			output.push ({
				"title": item.title,
				"match": alfredMatcher(item.title),
				"subtitle": item.summary,
				"arg": url,
				"uid": url,
			});
		});
	}

	return JSON.stringify({ items: output });
}
