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
	const vaultPath = $.getenv("vault_path");
	const shellCmd = `mdfind -onlyin "${vaultPath}" -name ".md"`;

	const items = app
		.doShellScript(shellCmd)
		.split("\r")
		.map((absPath) => {
			const parts = absPath.split("/");
			const name = parts.pop() || "";
			const parent = parts.join("/").slice(vaultPath.length + 1);
			const obsidianUri = "obsidian://open?path=" + encodeURIComponent(absPath);

			return {
				title: name,
				subtitle: "▸ " + parent,
				arg: absPath,
				uid: absPath,
				variables: { uri: obsidianUri },
				quicklookurl: absPath,
				type: "file:skipcheck",
				match: alfredMatcher(name),
				icon: { path: absPath, type: "fileicon" },
			};
		});

	return JSON.stringify({
		items: items,
		cache: { seconds: 600, loosereload: true },
	});
}
