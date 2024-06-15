#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const apps = app
		.doShellScript("mdfind \"kMDItemKind == 'Application'\"")
		.split("\r")
		.map((path) => {
			if (
				!path.endsWith(".app") ||
				(path.startsWith("/System/Library/CoreServices/") && !path.endsWith("Finder.app"))
			)
				return {};
			const appName = (path.split("/").pop() || "").slice(0, -4);
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
