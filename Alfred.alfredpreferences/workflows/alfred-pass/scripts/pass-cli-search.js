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

	// GUARD
	if (!Application("Finder").exists(Path(passwordStore))) {
		return JSON.stringify({
			items: { title: "⚠️ Password Store not found.", subtitle: passwordStore, valid: false },
		});
	}

	/** @type{AlfredItem[]} */
	const passwords = app
		.doShellScript(`cd "${passwordStore}" ; find . -type f -name "*.gpg" -not -path "./.git*"`)
		.split("\r")
		.map((gpgFile) => {
			const id = gpgFile.slice(2, -4);
			const pathParts = id.split("/");
			const name = pathParts.pop() || "ERROR";
			const group = pathParts.join("/");
			const path = `${passwordStore}/${gpgFile}`;
			return {
				title: name,
				subtitle: group,
				arg: id,
				uid: id,
				mods: {
					alt: { arg: path }, // reveal in finder directly uses path
					shift: {
						arg: "",
						variables: { entry: id },
					},
				},
			};
		});

	// new password
	const disallowed = { subtitle: "🚫 Not possible for new password.", valid: false };
	passwords.push({
		title: "Create New Password",
		arg: "",
		mods: {
			cmd: disallowed,
			shift: disallowed,
			alt: disallowed,
			ctrl: disallowed,
		},
	});

	return JSON.stringify({ items: passwords });
}
