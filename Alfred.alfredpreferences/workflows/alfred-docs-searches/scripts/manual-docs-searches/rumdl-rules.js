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
	const docsUrl = "https://raw.githubusercontent.com/rvben/rumdl/refs/heads/main/docs/RULES.md";
	const baseUrl = "https://github.com/rvben/rumdl/blob/main/docs";

	const workArray = httpRequest(docsUrl)
		.split("\n")
		.flatMap((line) => {
			const [_, id, name, desc] =
				line.match(/^\|.*?(MD\d{3}).*?\| *(.*?) *\| *(.*?) *\|$/) || [];
			if (!(id && name && desc)) return [];

			const url = `${baseUrl}/${id.toLowerCase()}.md`;
			const num = id.match(/\d\d$/)?.[0] || "";

			return {
				title: name,
				subtitle: `${id}: ${desc}`,
				match: [id, num, name].join(" "),
				mods: {
					cmd: { arg: id }, // copy entry
				},
				arg: url,
				quicklookurl: url,
				uid: id,
			};
		});

	return JSON.stringify({
		items: workArray,
		cache: {
			seconds: 3600 * 24 * 7, // 7 days
			loosereload: true,
		},
	});
}
