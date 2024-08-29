#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function camelCaseMatch(str) {
	const subwords = str.replace(/[-_./]/g, " ");
	const fullword = str.replace(/[-_./]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [subwords, camelCaseSeparated, fullword, str].join(" ") + " ";
}

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
			items: { title: "⚠️ Password store not found.", subtitle: passwordStore, valid: false },
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
			const matcher = camelCaseMatch(name) + camelCaseMatch(group);

			return {
				title: name,
				subtitle: group,
				arg: id,
				uid: id,
				match: matcher,
				variables: { entry: id },
				mods: {
					alt: { arg: path }, // revealing in Finder needs path
					shift: { arg: "" }, // keep next Alfred prompt clear
				},
			};
		});

	return JSON.stringify({ items: passwords });
}
