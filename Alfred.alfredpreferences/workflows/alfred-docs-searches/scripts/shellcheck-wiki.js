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
			const subsite = line.replace(ahrefRegex, "$1");
			if (subsite === "</li>") return {};
			const desc = line.replace(ahrefRegex, "$2").replaceAll("&ndash;", "").trim();
			const url = baseURL + subsite;
			let matcher = subsite;

			// if rule with number, add the number alone to the matcher as well
			const hasNumber = subsite.match(/\d{4}$/);
			if (hasNumber) matcher += " " + hasNumber[0].toString();

			return {
				title: subsite,
				subtitle: desc,
				match: matcher,
				arg: url,
				uid: url,
			};
		});

	return JSON.stringify({ items: jsonArr });
}
