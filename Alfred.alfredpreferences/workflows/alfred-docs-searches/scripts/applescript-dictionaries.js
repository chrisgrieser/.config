#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const appsWithDict = app
		// Caveat: Script Editor does not have .sdef file
		.doShellScript(`find \
			'/Applications' \
			"$HOME/Applications" \
			'/System/Applications' \
			'/System/Library/CoreServices' \
			'/System/Library/ScriptingAdditions' \
			-path '*/Contents/Resources/*.sdef' -mindepth 4 -maxdepth 4
		`)
		.split("\r")
		.map((sdefPath) => {
			const appPath = sdefPath.replace(/(.*\/.*?\.(?:app|osax))\/.*\.sdef/, "$1");
			const appName = appPath.split("/").pop().split(".")[0];
			return {
				title: appName,
				icon: { path: appPath, type: "fileicon" },
				arg: sdefPath,
			};
		});
	return JSON.stringify({
		items: appsWithDict,
		cache: { seconds: 1800 },
	});
}
