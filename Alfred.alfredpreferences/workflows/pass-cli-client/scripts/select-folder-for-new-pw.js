#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const jsonArray = [];

// INFO password store location retrieved via .zshenv
let passwordStore = app.doShellScript('echo "$PASSWORD_STORE_DIR"');
if (passwordStore === "") passwordStore = app.pathTo("home folder") + "/.password-store";

app
	.doShellScript(`cd "${passwordStore}" ; find . -type d -not -path "*/.git*"`)
	.split("\r")
	.slice(1) // first entry removed (root)
	.forEach((/** @type {string} */ folder) => {
		jsonArray.push({
			title: folder.slice(2), // remove leading "./"
			arg: folder,
			uid: folder,
			mods: {
				cmd: { variables: { generatePassword: true } },
			},
		});
	});

JSON.stringify({
	variables: { generatePassword: false },
	items: jsonArray,
});
