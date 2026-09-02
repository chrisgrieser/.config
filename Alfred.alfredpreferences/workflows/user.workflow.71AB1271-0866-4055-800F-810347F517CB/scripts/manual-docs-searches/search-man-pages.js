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

/** @typedef {Object} MankierPage
 * @property {string} name
 * @property {string} section
 * @property {string} description
 * @property {boolean} is_alias
 * @property {string} url
 */

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

	const response = httpRequest(apiUrl + firstWord);
	const /** @type{MankierPage[]} */ results = JSON.parse(response).results;

	/** @type{AlfredItem[]} */
	const manPages = results
		.map((result) => {
			const cmd = result.is_alias ? result.url.split("/").at(-1) || "" : result.name;
			const isInstalled = installedBinaries.includes(cmd);
			const aliasSuffix = result.is_alias ? " (alias)" : "";
			const icon = isInstalled ? " ✅" : "";
			let matcher = alfredMatcher(cmd);
			if (result.is_alias) matcher += alfredMatcher(result.name);

			return {
				title: result.name + aliasSuffix + icon,
				subtitle: `(${result.section})  ${result.description}`,
				match: matcher,
				uid: cmd,
				mods: {
					cmd: { valid: false, subtitle: "⛔ not supported" },
					alt: { valid: false, subtitle: "⛔ not supported" },
				},
				arg: remainingQuery, // pass to next script filter
				variables: { cmd: cmd, section: result.section }, // next script filter
				isInstalled: isInstalled, // just for sorting, not for Alfred
			};
		})
		.sort((a, b) => {
			if (a.isInstalled && !b.isInstalled) return -1;
			if (!a.isInstalled && b.isInstalled) return 1;
			return 0;
		});

	return JSON.stringify({ items: manPages });
}
