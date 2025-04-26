#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const baseURL = "https://www.shellcheck.net/wiki/";
	const ahrefRegex = /.*?href='(.*?)'>.*?<\/a>(.*?)(<\/li>|$)/i;

	const jsonArr = app
		.doShellScript(`curl -sL '${baseURL}'`)
		.split("\r")
		.slice(3, -1)
		.map((/** @type {string} */ line) => {
			const title = line.replace(ahrefRegex, "$1");
			if (title === "</li>") return {};
			const desc = line.replace(ahrefRegex, "$2").replaceAll("&ndash;", "").trim();
			const url = baseURL + title;

			// if rule with number, add the number alone to the matcher as well
			const hasNumber = title.match(/\d{4}$/);
			const numberMatcher = hasNumber ? " " + hasNumber[0] : "";

			return {
				title: title,
				subtitle: desc,
				match: title + numberMatcher,
				mods: {
					cmd: { arg: title }, // copy entry
				},
				arg: url,
				quicklookurl: url,
				uid: url,
			};
		});

	return JSON.stringify({
		items: jsonArr,
		cache: {
			seconds: 3600 * 24 * 7, // 7 days
			loosereload: true,
		},
	});
}
