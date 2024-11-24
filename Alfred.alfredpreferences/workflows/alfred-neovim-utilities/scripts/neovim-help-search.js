#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function camelCaseMatch(str) {
	const specialChars = /[-_.:]/g;
	const subwords = str.replace(specialChars, " ");
	const fullword = str.replace(specialChars, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");

	// e.g., so "setext" matches "nvim_buf_set_extmark()"
	const partial = str.replace(/^nvim_(win|buf)_/, "").replace(specialChars, "");
	const partial2 = str.replace(/^nvim_/, "").replace(specialChars, "");

	return [subwords, camelCaseSeparated, fullword, partial, partial2, str].join(" ") + " ";
}

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
	const helpIndexUrl =
		"https://raw.githubusercontent.com/chrisgrieser/alfred-neovim-utilities/main/.github/help-index/neovim-help-index-urls.txt";

	const items = httpRequest(helpIndexUrl)
		.split("\n")
		.map((url) => {
			const site = (url.split("/").pop() || "ERROR").split(".").shift();
			let name = (url.split("#").pop() || "ERROR").replaceAll("%3A", ":").replaceAll("'", "");
			let synonyms = "";

			const hasSynonyms = url.includes(",");
			const isSection = url.includes("\t");
			if (hasSynonyms) {
				synonyms = " " + url.split(",").pop();
				url = url.split(",").shift() || "ERROR";
				name = name.split(",").shift() || "ERROR";
			} else if (isSection) {
				url = url.split("\t").shift() || "ERROR";
				name = name.replace("\t", " ");
			}

			// matcher improvements
			let matcher = camelCaseMatch(name) + site + camelCaseMatch(synonyms);
			if (site === "builtin") matcher += " fn";
			if (name.includes("_hl")) matcher += " highlight";

			return {
				title: name + synonyms,
				match: matcher,
				subtitle: site,
				arg: url,
				quicklookurl: url,
				uid: url,
			};
		});

	return JSON.stringify({
		items: items,
		cache: {
			seconds: 3600 * 24 * 7, // every week
			loosereload: true,
		},
	});
}
