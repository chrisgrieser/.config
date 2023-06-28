#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const passwords = [];
	let passwordStore = argv[0];
	if (passwordStore === "") passwordStore = app.pathTo("home folder") + "/.password-store";
	const query = argv[1].trim();

	if (!fileExists(passwordStore)) {
		passwords.push({
			title: "⚠️ Password Store not found.",
			subtitle: passwordStore,
			valid: false,
		});
		return JSON.stringify({ items: passwords });
	}

	// `-iname` makes the search case-insensitive
	const passwordlist = app.doShellScript(
		`cd "${passwordStore}" ; ` +
			`find . -iname "*${query}*.gpg" -or -ipath "*${query}*" -type f -and -not -name ".DS_Store"`,
	);
	let createNewPassword;
	if (passwordlist) {
		createNewPassword = false;
		passwordlist.split("\r").forEach((gpgFile) => {
			const id = gpgFile.slice(2, -4);
			const parts = id.split("/");
			const name = parts.pop();
			const group = parts.join("/");
			const path = `${passwordStore}/${group}/${name}.gpg`;

			passwords.push({
				title: name,
				subtitle: group,
				arg: id,
				uid: id,
				mods: {
					alt: { arg: path },
					// move id to variable for Alfred Script Filter
					shift: {
						variables: { entry: id },
						arg: "",
					},
				},
			});
		});
	} else {
		createNewPassword = true;
		const cleanQuery = query.replace(/[/\\:]/, "-");
		const disallowed = { subtitle: "🚫 Not possible for new password.", valid: false };
		passwords.push({
			title: "🆕 " + query,
			subtitle: "Create new password",
			arg: cleanQuery,
			mods: {
				cmd: disallowed,
				shift: disallowed,
				alt: disallowed,
				ctrl: disallowed,
			},
		});
	}

	return JSON.stringify({
		variables: { createNewPassword: createNewPassword }, // boolean passed as 1/0
		items: passwords,
	});
}
