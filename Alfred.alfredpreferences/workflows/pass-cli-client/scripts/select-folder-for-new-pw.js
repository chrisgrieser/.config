#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const passwordFolders = [];

// INFO password store location retrieved via .zshenv
let passwordStore = app.doShellScript('echo "$PASSWORD_STORE_DIR"');
if (passwordStore === "") passwordStore = app.pathTo("home folder") + "/.password-store";

app
	.doShellScript(`cd "${passwordStore}" ; find . -type d -not -path "*/.git*"`)
	.split("\r")
	.forEach((/** @type {string} */ folder) => {
		folder = folder.slice(2); // remove leading "./"
		if (!folder) folder = "* root";
		passwordFolders.push({
			title: folder,
			arg: folder,
			uid: folder,
			mods: {
				cmd: {
					subtitle: "⌘↵: Insert password from clipboard",
					variables: { generatePassword: false },
				},
			},
		});
	});

// move root to the back of the list
passwordFolders.push(passwordFolders.shift())

JSON.stringify({
	variables: { generatePassword: true },
	items: passwordFolders,
});
