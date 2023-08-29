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
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const ruffRulesUrl = "https://beta.ruff.rs/docs/rules/";

	const sectionsArr = app
		.doShellScript(`curl -s "${ruffRulesUrl}" | grep -A1 "<td id="`)
		.split("\r--\r") // grep delimiter
		.map((ruleInfo) => {
			let [id, name] = ruleInfo.split("\r");
			id = id.match(/id="(.*?)"/)[1];
			name = name.includes("href") ? name.match(/href="(.*?)\/"/)[1] : name.match(/>(.*?)<.*/)[1];
			const displayName = name.replace(/-/g, " ");

			const url = ruffRulesUrl + name + "/";

			/** @type{AlfredItem} */
			const item = {
				title: displayName,
				subtitle: id,
				match: alfredMatcher(id) + alfredMatcher(name),
				arg: url,
				uid: url,
			};
			return item
		});

	return JSON.stringify({ items: sectionsArr });
}
