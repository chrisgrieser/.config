#!/usr/bin/env osascript -l JavaScript

function run (argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;
	const alfredMatcher = (str) => str.replace (/[-()_.:#]/g, " ")
		+ " " + str + " "
		+ str.replace(/([A-Z])/g, " $1"); // match parts of CamelCase
	const onlineJSON = (url) => JSON.parse (app.doShellScript(`curl -sL '${url}'`));

	//------------------------------------------------------------------------------

	const input = argv.join("").split(" ");
	const lang = input.shift();
	const query = input.join(" ");
	console.log(lang + " " + query);
	const baseURL = "https://developer.mozilla.org";
	const searchAPI = "https://developer.mozilla.org/api/v1/search?q=";
	console.log(searchAPI + query);

	const resultsArr = onlineJSON(searchAPI + query)
		.documents
		.filter(result => result.mdn_url.includes(lang));
	let output = [];

	if (resultsArr.length === 0) {
		output = [{
			"title": "No documents found.",
			"subtitle": "MDN search sometimes requires longer queries before results are shown.",
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
