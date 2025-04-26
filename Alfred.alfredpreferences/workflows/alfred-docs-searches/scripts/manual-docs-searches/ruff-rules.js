#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[<_-]/g, " ");
	const numberSeparated = str.replace(/(\d+)/g, " $1");
	return [clean, str, numberSeparated].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const ruffRulesUrl = "https://docs.astral.sh/ruff/rules/";

	const sectionsArr = app
		.doShellScript(`curl -s "${ruffRulesUrl}" | grep -A1 "<td id="`)
		.split("\r--\r") // grep delimiter
		.map((ruleInfo) => {
			const [idRaw, nameRaw] = ruleInfo.split("\r");
			const [_, id] = idRaw.match(/id="(.*?)"/) || [];
			const [__, name] = nameRaw.includes("href")
				? nameRaw.match(/href="(.*?)\/"/) || []
				: nameRaw.match(/>(.*?)<.*/) || [];
			const displayName = name.replace(/-/g, " ");
			const url = ruffRulesUrl + name + "/";

			/** @type{AlfredItem} */
			const item = {
				title: displayName,
				subtitle: id,
				match: alfredMatcher(id) + alfredMatcher(name),
				arg: url,
				quicklookurl: url,
				mods: {
					cmd: { arg: name }, // copy entry
				},
				uid: url,
			};
			return item;
		});

	return JSON.stringify({
		items: sectionsArr,
		cache: {
			seconds: 3600 * 24 * 7, // 7 days
			loosereload: true,
		},
	});
}
