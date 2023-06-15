#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}
const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));
const home = app.pathTo("home folder");

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	let passwordStore = argv[0]; // INFO password store location retrieved via .zshenv
	if (passwordStore === "") passwordStore = home + "/.password-store";
	const jsonArray = [];

	if (!fileExists(passwordStore)) {
		jsonArray.push({
			title: "⚠️ Password Store does not exist",
			subtitle: passwordStore,
			valid: false,
		});
		return JSON.stringify({ items: jsonArray });
	}

	app
		.doShellScript(`cd "${passwordStore}" ; find . -name "*.gpg"`)
		.split("\r")
		.forEach((/** @type {string} */ gpgFile) => {
			const id = gpgFile.slice(2, -4);
			const parts = id.split("/");
			const name = parts.pop();
			const group = parts.join("/");

			jsonArray.push({
				title: name,
				subtitle: group,
				match: alfredMatcher(id),
				arg: id,
				uid: id,
			});
		});

	app
		.doShellScript(`cd "${passwordStore}" ; find . -type d -not -path "*/.git*"`)
		.split("\r")
		.slice(1) // first entry removed (root)
		.forEach((/** @type {string} */ folder) => {

			jsonArray.push({
				title: folder.slice(2),// remove leading "./"
				icon: { path: "pw-folder.png" },
				subtitle: "Create new entry in folder",
				match: alfredMatcher(folder) + " new folder",
				arg: "*" + folder,
				uid: folder,
				mods: {
					// disallow entry-actions
					cmd: { valid: false },
					shift: { valid: false },
					"fn+cmd": { valid: false },
					ctrl: { valid: false },
				},
			});
		});

	return JSON.stringify({ items: jsonArray });
}
