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
function run() {
	const htmlUrl = "https://www.tofugu.com/japanese-grammar/";
	const response = httpRequest(htmlUrl);

	const guides = response
		.split("\n")
		.filter((line) => line.startsWith("<a href='/japanese-grammar/"))
		.map((line) => {
			console.log("🖨️ line:", line);
			// example: <a href='/japanese-grammar/dake/' title='View だけ'>
			const [_, subsite, name] = line.match(/<a href='japanese-grammar\/(.*)' title='View (.*)/) || [];
			const url = htmlUrl + subsite;

			/** @type {AlfredItem} */
			const alfredItem = {
				title: subsite + " " + name,
				subtitle: url,
				arg: url,
				quicklookurl: url,
			};
			return alfredItem;
		});

	return JSON.stringify({ items: guides });
}
