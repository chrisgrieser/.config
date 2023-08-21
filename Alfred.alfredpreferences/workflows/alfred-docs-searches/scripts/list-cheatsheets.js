#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const alfredMatcher = (/** @type {string} */ str) => str.replace(/[-()/_.:]/g, " ") + " " + str + " ";

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const jsonArray = app
		.doShellScript("curl 'https://cheat.sh/:list'")
		.split("\r")
		.filter((line) => !line.endsWith(":list") && !line.endsWith("/") && !line.startsWith(":"))
		.concat([":intro", ":styles-demo", ":styles", ":vim", ":random"])
		.map((item) => {
			return {
				title: item,
				match: alfredMatcher(item),
				arg: "https://cheat.sh/" + item,
				uid: item,
			};
		});

	return JSON.stringify({ items: jsonArray });
}
