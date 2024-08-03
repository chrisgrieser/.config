#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_().:#;,[\]'"]/g, " ");
	return [clean, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// CONFIG
	const folderToSearch = app.pathTo("home folder");
	const maxItems = 10;
	// INFO `fd` does not allow to sort results by recency, thus using `rg` instead
	const rgCmd =
		"rg --no-config --files --sortr=modified --glob='!/Library/' --glob='!*.photoslibrary'";

	/** @type {AlfredItem[]} */
	const recentlyChanged = app
		.doShellScript(`cd '${folderToSearch}' && ${rgCmd}`)
		.split("\r")
		.slice(0, maxItems)
		.map((relPath) => {
			const [_, parent, name] = relPath.match(/(.*\/)(.*\/?)/) || [];
			const absPath = folderToSearch + "/" + relPath;

			/** @type {AlfredItem} */
			const item = {
				title: name,
				subtitle: parent.slice(0, -1),
				arg: absPath,
				type: "file:skipcheck",
				match: alfredMatcher(name),
				icon: { type: "fileicon", path: absPath },
			};
			return item;
		});

	return JSON.stringify({ items: recentlyChanged });
}
