#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_]/g, " ");
	const squeezed = str.replace(/[-_]/g, "");
	return [clean, squeezed, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// DOCS https://www.mankier.com/api
	const sectionApiUrl = `https://www.mankier.com/api/v2/mans/${$.getenv("cmd")}.${$.getenv("section")}`;

	// local binaries
	const installedBinaries = app
		.doShellScript(
			"echo $PATH | tr ':' '\n' | xargs -I {} find {} -mindepth 1 -maxdepth 1 -type f -or -type l -perm '++x' | xargs basename",
		)
		.split("\r");

	/** @type{AlfredItem[]} */
	const sections = JSON.parse(httpRequest(sectionApiUrl)).sections.map((section) => ({
		title: section.title,
		match: alfredMatcher(section.title),
		arg: section.url,
		uid: section,
	}));

	return JSON.stringify({ items: sections });
}
