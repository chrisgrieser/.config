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
	const baseURL2 = "https://cssreference.io/";
	const output = [];

	if (lang === "CSS") {
		app.doShellScript(`curl -sL "${baseURL2}" | grep "<article"`)
			.match(/data-property-name=".+?"/g)
			.map(item => item.slice(20, -1)) // eslint-disable-line no-magic-numbers
			.filter(item => item.includes(query)) // since filtered not filtered by Alfred
			.forEach(item => {
				const url = `${baseURL2}/property/${item}`;
				output.push ({
					"title": item,
					"match": alfredMatcher(item),
					"subtitle": "visual reference",
					"arg": url,
					"uid": url,
					"icon": { "path": "./css.png" },
				});
			});
	}

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
