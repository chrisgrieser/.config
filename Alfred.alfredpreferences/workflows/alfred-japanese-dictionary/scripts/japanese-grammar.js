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

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_#/.:;,()[\]]/g, " ");
	return [clean, str].join(" ") + " ";
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
			// example: <a href='/japanese-grammar/dake/' title='View だけ'>
			const [_, subsite, name] =
				line.match(/<a href='\/japanese-grammar\/(.*)' title='View (.*)'>/) || [];
			const url = htmlUrl + subsite;
			const romaji = subsite.replaceAll("/", "").replaceAll("-", " ");
			const displayName = name.replaceAll("&#39;", "'").replaceAll("&quot;", '"');

			/** @type {AlfredItem} */
			const alfredItem = {
				title: displayName,
				match: alfredMatcher(name) + alfredMatcher(romaji),
				arg: url,
				quicklookurl: url,
				uid: url,
			};
			return alfredItem;
		});

	return JSON.stringify({
		items: guides,
		cache: { seconds: 60 * 60 * 24, loosereload: true },
	});
}
