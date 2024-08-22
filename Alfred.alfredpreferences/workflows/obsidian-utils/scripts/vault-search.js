#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_()[\]]/g, " ");
	return [clean, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const shellCmd = `cd "${$.getenv("vault_path")}" && rg --no-config --files --sortr=modified`;

	const items = app
		.doShellScript(shellCmd)
		.split("\r")
		.map((relPath) => {
			const parts = relPath.split("/");
			const name = parts.pop() || "";
			const parent = parts.join("/");
			const absPath = $.getenv("vault_path") + "/" + relPath;

			return {
				title: name,
				subtitle: "▸ " + parent,
				arg: absPath,
				quicklookurl: absPath,
				type: "file:skipcheck",
				match: alfredMatcher(name),
				icon: { path: absPath, type: "fileicon" },
			};
		});

	return JSON.stringify({
		items: items,
		cache: { seconds: 3600, loosereload: true },
	});
}
