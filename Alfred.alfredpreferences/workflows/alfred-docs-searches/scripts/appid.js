#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const apps = app
		.doShellScript(`find \
			"/Applications" \
			"/Applications/Utilities" \
			"$HOME/Applications" \
			"/System/Applications" \
			"/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app" \
			"/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app" \
			"/System/Library/CoreServices/Finder.app" \
			-name '*.app' -maxdepth 1 -type d
		`)
		.split("\r")
		.map((path) => {
			const appName = path.split("/").pop().slice(0, -4);
			return {
				title: appName,
				type: "file:skipcheck",
				icon: { path: path, type: "fileicon" },
				arg: appName,
			};
		});

	return JSON.stringify({
		items: apps,
		cache: { seconds: 1800 },
	});
}
