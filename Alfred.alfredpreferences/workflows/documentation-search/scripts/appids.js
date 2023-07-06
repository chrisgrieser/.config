#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const scriptFilterArr = app
		.doShellScript(`find \
			'/Applications' \
			"$HOME/Applications" \
			'/System/Applications' \
			-name '*.app' -maxdepth 1 -type d
		`)
		.split("\r")
		.map((path) => {
			const appName = path.split("/").pop().slice(0, -4);
			return {
				title: appName,
				type: "file:skipcheck",
				icon: { path: path, type: "fileicon"},
				arg: appName,
			};
		});
	return JSON.stringify({ items: scriptFilterArr });
}
