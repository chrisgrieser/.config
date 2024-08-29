#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const passwordStore =
		// executing `zsh` instead of sourcing because https://github.com/chrisgrieser/alfred-pass/issues/4
		app.doShellScript("exec zsh -c 'echo \"$PASSWORD_STORE_DIR\"'") ||
		app.pathTo("home folder") + "/.password-store";

	/** @type{AlfredItem[]} */
	const passwordFolders = app
		.doShellScript(`cd "${passwordStore}" ; find . -type d -not -path "./.git*"`)
		.split("\r")
		.map((/** @type {string} */ folder) => {
			const folderShort = folder.slice(2) || "* root"; 
			return {
				title: `📂 ${folderShort}`,
				arg: "",
				variables: { folder: folderShort },
			};
		});

	// move root to the bottom of the list
	passwordFolders.push(/** @type {AlfredItem} */ (passwordFolders.shift()));

	return JSON.stringify({ items: passwordFolders });
}
