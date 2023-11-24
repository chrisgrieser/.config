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

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// DOCS https://www.mankier.com/api
	const baseUrl = "https://www.mankier.com/1/";
	const apiUrl = "https://www.mankier.com/api/v2/mans/?q=fd"

	// process Alfred args
	const query = argv[0] || "";
	const command = query.split(" ")[0];
	const options = argv[0] ? query.split(" ").slice(1).join(" ") : "";

	const installedBinaries = app
		.doShellScript(
			"echo $PATH | tr ':' '\n' | xargs -I {} find {} -mindepth 1 -maxdepth 1 -type f -or -type l -perm '++x'",
		)
		.split("\r")
		.filter((binary) => binary.includes(command));

	/** @type{AlfredItem[]} */
	const manPages = JSON.parse(httpRequest(apiUrl))
		.results
		.map((cmd) => {
			let url = baseUrl + cmd;
			if (options) url += "#" + options;
			const icon = 

			return {
				title: [cmd, options, icon].filter(Boolean).join(" "),
				match: cmd.replace(/[-_]/, " ") + " " + cmd,
				arg: url,
				mods: {
					cmd: {
						arg: "man " + argv[0],
						subtitle: "⌘: Open in Terminal >> man " + argv[0],
					},
				},
				uid: cmd,
			};
		})
		.sort((a, b) => {
			// sort by length (shorter on top), then alphabetically
			const diff = a.uid.length - b.uid.length;
			if (diff !== 0) return diff;
			return a.uid.localeCompare(b.uid);
		});

	return JSON.stringify({ items: binariesArr });
}
