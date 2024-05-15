#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const finder = Application("Finder");
	const finderWinPath = decodeURIComponent(finder.insertionLocation().url().slice(7));

	const itemsInWindow = app
		.doShellScript(`find "${finderWinPath}" -maxdepth 1 -mindepth 1`)
		.split("\r")
		.map((absPath) => {
			if (absPath.endsWith(".DS_Store")) return {};
			const name = absPath.split("/").pop();

			return {
				title: name,
				arg: absPath,
				icon: { type: "fileicon", path: absPath },
				type: "file:skipcheck",
			};
		});

	return JSON.stringify({ items: itemsInWindow });
}
