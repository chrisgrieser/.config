#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// CONFIG
	const folderToSearch = app.pathTo("home folder");
	const maxItems = 10;
	const rgCmd =
		"rg --no-config --files --sortr=modified --glob='!/Library/' --glob='!*.photoslibrary'";

	/** @type AlfredItem[] */
	const recentlyChanged = app
		.doShellScript(`cd "${folderToSearch}" && ${rgCmd}`)
		.split("\r")
		.slice(0, maxItems)
		.map((relPath) => {
			const [_, parent, name] = relPath.match(/(.*\/)(.*\/?)/) || [];

			/** @type {AlfredItem} */
			const item = {
				title: name,
				subtitle: parent.slice(0, -1),
				arg: folderToSearch + "/" + relPath,
				type: "file:skipcheck",
			};
			return item;
		});
	console.log("🖨️ recentlyChanged:", JSON.stringify(recentlyChanged));

	return JSON.stringify({ items: recentlyChanged });
}
