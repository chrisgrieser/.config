#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

//───────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const lang = argv[0];
	const query = argv.slice(1).join("");

	const baseURL = "https://developer.mozilla.org";
	const searchAPI = "https://developer.mozilla.org/api/v1/search?q=";
	const output = [];

	const resultsArr = JSON.parse(httpRequest(searchAPI + encodeURIComponent(query))).documents.filter(
		(/** @type {{ mdn_url: string; }} */ result) => result.mdn_url.includes(lang),
	);

	if (resultsArr.length === 0) {
		output.push({
			title: "No MDN documents found.",
			subtitle: "MDN search sometimes requires longer queries before results are shown.",
			valid: false,
			arg: "no",
		});
	} else {
		resultsArr.forEach((/** @type {{ mdn_url: string; title: string; summary: any; }} */ item) => {
			const url = baseURL + item.mdn_url;
			output.push({
				title: item.title,
				match: alfredMatcher(item.title),
				subtitle: item.summary,
				arg: url,
				uid: url,
			});
		});
	}

	return JSON.stringify({ items: output });
}
