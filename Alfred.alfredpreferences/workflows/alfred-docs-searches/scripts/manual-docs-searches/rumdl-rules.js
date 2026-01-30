#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const jsonUrl = "https://raw.githubusercontent.com/rvben/rumdl/main/rules.json";

	const workArray = JSON.parse(httpRequest(jsonUrl)).map(
		(
			/** @type {{ code: string; name: string; summary: string; category: string; url: string; }} */ rule,
		) => {
			const { code, name, summary, category, url } = rule;

			return {
				title: `${code} – ${name}`,
				subtitle: `[${category}] ${summary}`,
				match: [code, name, category, summary].join(" "),
				mods: {
					cmd: { arg: code }, // copy entry
				},
				arg: url,
				quicklookurl: url,
				uid: code,
			};
		},
	);

	return JSON.stringify({
		items: workArray,
		cache: {
			seconds: 3600 * 24 * 7, // 7 days
			loosereload: true,
		},
	});
}
