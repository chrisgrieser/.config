#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
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
	// DOCS https://man7.org/linux/man-pages/man7/man-pages.7.html
	const sections = "1,1p,2,5,7,8";
	// DOCS https://www.mankier.com/api
	const apiUrl = `https://www.mankier.com/api/v2/mans/?sections=${sections}&q=`;

	// process Alfred args
	const query = argv[0];
	if (!query) {
		return JSON.stringify({ items: [{ title: "Waiting for query…", valid: false }] });
	}
	const firstWord = query.split(" ")[0];
	const remainingQuery = query.split(" ").slice(1).join(" ");

	// local binaries
	const shellCmd =
		"echo $PATH | tr ':' '\n' | xargs -I {} find {} -mindepth 1 -maxdepth 1 -type f -or -type l -perm '++x' | xargs basename";
	const installedBinaries = app.doShellScript(shellCmd).split("\r");

	/** @type{AlfredItem[]} */
	const manPages = JSON.parse(httpRequest(apiUrl + firstWord)).results.map(
		(
			/** @type {{ name: string; section: string; description: string; is_alias: boolean; url: string; }} */ result,
		) => {
			const cmd = result.is_alias ? result.url.split("/").at(-1) || "" : result.name;
			const aliasSuffix = result.is_alias ? " (alias)" : "";
			const icon = installedBinaries.includes(cmd) ? " ✅" : "";
			let matcher = alfredMatcher(cmd);
			if (result.is_alias) matcher += alfredMatcher(result.name);

			return {
				title: result.name + aliasSuffix + icon,
				subtitle: `(${result.section})  ${result.description}`,
				match: matcher,
				uid: cmd,
				arg: remainingQuery, // pass to next script filter
				variables: {
					cmd: cmd,
					section: result.section,
				},
			};
		},
	);

	return JSON.stringify({ items: manPages });
}
