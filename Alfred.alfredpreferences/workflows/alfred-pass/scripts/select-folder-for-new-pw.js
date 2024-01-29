#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const passwordStore =
		app.doShellScript('source "$HOME/.zshenv" ; echo "$PASSWORD_STORE_DIR"') ||
		app.pathTo("home folder") + "/.password-store";

	/** @type{AlfredItem[]} */
	const passwordFolders = app
		.doShellScript(`cd "${passwordStore}" ; find . -type d -not -path "./.git*"`)
		.split("\r")
		.map((/** @type {string} */ folder) => {
			const displayName = folder.slice(2) || "* root"; 
			return {
				title: `📂 ${displayName}`,
				arg: "",
				variables: { folder: folder },
			};
		});

	// move root to the bottom of the list
	passwordFolders.push(passwordFolders.shift());

	return JSON.stringify({ items: passwordFolders });
}
