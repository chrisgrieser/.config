#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let passwordStore = app.doShellScript('source "$HOME/.zshenv" ; echo "$PASSWORD_STORE_DIR"');
	if (passwordStore === "") passwordStore = app.pathTo("home folder") + "/.password-store";
	console.log("👽 passwordStore:", passwordStore);

	if (!fileExists(passwordStore)) {
		return JSON.stringify({
			items: {
				title: "⚠️ Password Store not found.",
				subtitle: passwordStore,
				valid: false,
			},
		});
	}

	/** @type{AlfredItem[]} */
	const passwords = app
		.doShellScript(`cd "${passwordStore}" ; find . -name "*.gpg"`)
		.split("\r")
		.map((gpgFile) => {
			const id = gpgFile.slice(2, -4);
			const pathParts = id.split("/");
			const name = pathParts.pop();
			const group = pathParts.join("/");
			const path = `${passwordStore}/${gpgFile}`;
			return {
				title: name,
				subtitle: group,
				arg: id,
				uid: id,
				mods: {
					// move id to variable for Alfred Script Filter
					shift: {
						variables: { entry: id },
						arg: "",
					},
					alt: { arg: path },
				},
			};
		});

	// new password
	passwords.push({
		
	})

	// let createNewPassword;
	// if (passwordlist) {
	// 	createNewPassword = false;
	// 	for (const gpgFile of passwordlist.split("\r")) {
	// 		const id = gpgFile.slice(2, -4);
	// 		const parts = id.split("/");
	// 		const name = parts.pop();
	// 		const group = parts.join("/");
	// 		const path = `${passwordStore}/${group}/${name}.gpg`;
	//
	// 		passwords.push({
	// 			title: name,
	// 			subtitle: group,
	// 			arg: id,
	// 			uid: id,
	// 			mods: {
	// 				// move id to variable for Alfred Script Filter
	// 				shift: {
	// 					variables: { entry: id },
	// 					arg: "",
	// 				},
	// 				alt: { arg: path },
	// 			},
	// 		});
	// 	}
	// } else {
	// 	createNewPassword = true;
	// 	const cleanQuery = query.replace(/[/\\:]/, "-");
	// 	const disallowed = { subtitle: "🚫 Not possible for new password.", valid: false };
	// 	passwords.push({
	// 		title: "🆕 " + query,
	// 		subtitle: "Create new password",
	// 		arg: cleanQuery,
	// 		mods: {
	// 			cmd: disallowed,
	// 			shift: disallowed,
	// 			alt: disallowed,
	// 			ctrl: disallowed,
	// 		},
	// 	});
	// }

	return JSON.stringify({
		// variables: { createNewPassword: createNewPassword }, // boolean passed as 1/0
		items: passwords,
	});
}
