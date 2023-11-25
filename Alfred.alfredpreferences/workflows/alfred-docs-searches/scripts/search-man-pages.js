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
	const apiUrl = "https://www.mankier.com/api/v2/mans/?sections=1,2,7,8&q=";

	// process Alfred args
	const query = argv[0];
	if (!query) {
		return JSON.stringify({ items: [{ title: "Waiting for query…", valid: false }] });
	}
	const firstWord = query.split(" ")[0];
	const remainingQuery = query.split(" ").slice(1).join(" ");

	// local binaries
	const installedBinaries = app
		.doShellScript(
			"echo $PATH | tr ':' '\n' | xargs -I {} find {} -mindepth 1 -maxdepth 1 -type f -or -type l -perm '++x' | xargs basename",
		)
		.split("\r");

	/** @type{AlfredItem[]} */
	const manPages = JSON.parse(httpRequest(apiUrl + firstWord)).results.map(
		(/** @type {{ name: string; section: string; description: string; }} */ result) => {
			const cmd = result.name;
			const section = result.section;
			const icon = installedBinaries.includes(cmd) ? " ✅" : "";

			return {
				title: cmd + icon,
				subtitle: `(${section})  ${result.description}`,
				match: alfredMatcher(cmd),
				uid: cmd,
				// pass to next script filter
				variables: { cmd: cmd, section: section },
				arg: remainingQuery,
			};
		},
	);

	return JSON.stringify({ items: manPages });
}
