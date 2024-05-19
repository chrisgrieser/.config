#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];
	const ddgrHtmlUrl = "https://html.duckduckgo.com/html?q=";
	const response = httpRequest(ddgrHtmlUrl + encodeURIComponent(query));
	const ddgPage = response.match(/<a href="([^"]+)">/)[1];
	const linkOfFirstResult = ddgPage.match(/https?:\/\/[^\/]+/)[0];
	return linkOfFirstResult;
}
