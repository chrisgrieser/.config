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
	const passwordFolders = [];

	const shellCmd = `cd "${passwordStore}" ; find . -type d -mindepth 1 -not -path "./.git*"`,
	const stdout = app.doShellScript(
	);
	if (stdout.trim() !== "") {
		stdout.split("\r").map((/** @type {string} */ folder) => {
			folder = folder.slice(2); // remove `./`
			return {
				title: "📂 " + folder,
				arg: "", // empty for next Alfred prompt
				variables: { folder: folder },
			};
		});
	}

	// add root at the bottom of the list
	passwordFolders.push({
		title: "📂 * root",
		arg: "",
		variables: { folder: "." },
	});

	return JSON.stringify({ items: passwordFolders });
}
