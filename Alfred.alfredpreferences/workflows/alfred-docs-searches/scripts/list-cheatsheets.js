#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const alfredMatcher = (/** @type {string} */ str) =>
	str.replace(/[-()/_.:]/g, " ") + " " + str + " ";

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const jsonArray = app
		.doShellScript("curl 'https://cheat.sh/:list'")
		.split("\r")
		.filter((line) => !line.endsWith(":list") && !line.endsWith("/") && !line.startsWith(":"))
		.concat([":intro", ":styles-demo", ":styles", ":vim", ":random"])
		.map((item) => {
			const url = "https://cheat.sh/" + item;
			return {
				title: item,
				match: alfredMatcher(item),
				arg: url,
				quicklookurl: url,
				uid: item,
			};
		});

	return JSON.stringify({
		items: jsonArray,
		cache: { seconds: 3600 * 24 },
	});
}
