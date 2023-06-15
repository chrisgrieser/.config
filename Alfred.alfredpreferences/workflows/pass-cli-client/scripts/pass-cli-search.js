#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const passwords = [];

	// INFO password store location retrieved via .zshenv
	let passwordStore = app.doShellScript('echo "$PASSWORD_STORE_DIR"');
	if (passwordStore === "") passwordStore = app.pathTo("home folder") + "/.password-store";

	if (!fileExists(passwordStore)) {
		passwords.push({
			title: "⚠️ Password Store does not exist",
			subtitle: passwordStore,
			valid: false,
		});
		return JSON.stringify({ items: passwords });
	}

	const query = argv[0];
	const passwordlist = app.doShellScript(`cd "${passwordStore}" ; find . -name "*${query}*.gpg"`);
	let createNewPassword;
	if (passwordlist) {
		createNewPassword = false;
		passwordlist.split("\r").forEach((/** @type {string} */ gpgFile) => {
			const id = gpgFile.slice(2, -4);
			const parts = id.split("/");
			const name = parts.pop();
			const group = parts.join("/");

			passwords.push({
				title: name,
				subtitle: group,
				arg: id,
				uid: id,
			});
		});
	} else {
		createNewPassword = true;
		passwords.push({
			title: "🆕 " + query,
			subtitle: "Create new password",
			arg: query,
		});
	}

	return JSON.stringify({
		variables: { createNewPassword: createNewPassword }, // boolean passed as 1/0
		items: passwords,
	});
}
