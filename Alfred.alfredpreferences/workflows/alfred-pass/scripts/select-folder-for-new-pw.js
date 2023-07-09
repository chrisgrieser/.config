#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	let passwordStore = argv[0];
	if (passwordStore === "") passwordStore = app.pathTo("home folder") + "/.password-store";

	/** @type{AlfredItem[]} */
	const passwordFolders = app
		.doShellScript(`cd "${passwordStore}" ; find . -type d -not -path "*/.git*"`)
		.split("\r")
		.map((/** @type {string} */ folder) => {
			folder = folder.slice(2); // remove leading "./"
			if (!folder) folder = "* root";
			return {
				title: `📂 ${folder}`,
				arg: folder,
				variables: { generatePassword: true },
				mods: {
					cmd: {
						subtitle: "⌘↵: Insert password from clipboard",
						variables: { generatePassword: false },
					},
				},
			};
		});

	// move root to the bottom of the list
	passwordFolders.push(passwordFolders.shift());

	// discoverability: show alternate option on first
	passwordFolders[0].subtitle = "↵: Autogenerate password     ⌘↵: Password from clipboard";

	return JSON.stringify({ items: passwordFolders });
}
