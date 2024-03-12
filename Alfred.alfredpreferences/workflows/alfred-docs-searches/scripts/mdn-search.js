#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}
/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	const requestStr = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
	return requestStr;
}

//───────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	/** @type {Record<string, string>} */
	const keywordLangMap = { html: "HTML", css: "CSS", js: "JavaScript" };
	const scriptFilterKeyword = $.getenv("alfred_workflow_keyword") || "";
	const lang = keywordLangMap[scriptFilterKeyword];
	if (!lang) {
		console.log("Invalid keyword");
		return;
	}

	const query = (argv[0] || "").trim();
	const baseURL = "https://developer.mozilla.org";
	const searchAPI = "https://developer.mozilla.org/api/v1/search?q=";
	let results = JSON.parse(httpRequest(searchAPI + encodeURIComponent(query)));

	// FEAT use suggestion if there are no results
	if (results.documents.length === 0 && results.suggestions.length > 0) {
		const suggestion = results.suggestions[0].text;
		results = JSON.parse(httpRequest(searchAPI + encodeURIComponent(suggestion)));
	}

	const docs = results.documents
		.filter((/** @type {{ mdn_url: string; }} */ doc) => doc.mdn_url.includes(lang))
		.map((/** @type {{ mdn_url: string; title: string; summary: string; }} */ doc) => {
			const url = baseURL + doc.mdn_url;
			return {
				title: doc.title,
				match: alfredMatcher(doc.title),
				subtitle: doc.summary,
				arg: url,
				quicklookurl: url,
				uid: url,
			};
		});

	// GUARD no results
	if (docs.length === 0) {
		return JSON.stringify({
			items: [
				{
					title: "No MDN documents found.",
					subtitle: "MDN search sometimes requires longer queries before results are shown.",
					valid: false,
				},
			],
		});
	}

	return JSON.stringify({ items: docs });
}
