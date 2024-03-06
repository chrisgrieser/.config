#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function camelCaseMatch(str) {
	const clean = str.replace(/[-_.]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const luaVersion = "5.4";
	const luaManualBaseURL = `https://lua.org/manual/${luaVersion}/`;

	const rawHTML = app.doShellScript(`curl -sL '${luaManualBaseURL}'`);
	const ahrefRegex = /.*?href="(.*?)">(.*?)<.*/i;

	const sites = rawHTML
		.split("\r")
		.slice(40) // remove html header
		.filter((line) => line.includes("HREF"))
		.map((line) => {
			let [, subsite, title] = line.match(ahrefRegex) || [];
			if (!subsite) return {};
			title = title.replace(ahrefRegex, "$2").replace(/^[.0-9]+ &ndash; /, "");
			if (title.includes(">")) return {};
			const url = luaManualBaseURL + subsite;

			return {
				title: title,
				match: camelCaseMatch(title),
				arg: url,
				quicklookurl: url,
				uid: url,
			};
		});

	return JSON.stringify({
		items: sites,
		cache: { seconds: 3600 * 24 * 7 }, // 1 week
	});
}
