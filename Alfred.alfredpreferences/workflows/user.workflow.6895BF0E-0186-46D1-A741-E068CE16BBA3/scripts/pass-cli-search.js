#!/usr/bin/env osascript -l JavaScript
function run(argv) {

	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function alfredMatcher(str) {
		const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
		const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
		return [clean, camelCaseSeperated, str].join(" ");
	}
	const fileExists = (filePath) => Application("Finder").exists(Path(filePath));
	const home = app.pathTo("home folder");

	//──────────────────────────────────────────────────────────────────────────────
	let passwordStore = argv[0]; // INFO password store location retrieved via .zshenv
	if (passwordStore === "") passwordStore = home + "/.password-store";
	const jsonArray = [];

	if (fileExists(passwordStore)) {
		app.doShellScript(`cd "${passwordStore}" ; find . -name "*.gpg"`)
			.split("\r")
			.forEach(gpgFile => {
				const id = gpgFile.slice(2, -4);
				const parts = id.split("/");
				const name = parts.pop();
				const group = parts.join("/");

				jsonArray.push({
					"title": name,
					"subtitle": group,
					"match": alfredMatcher(id),
					"arg": id,
					"uid": id,
					"mods": {
						"fn": {
							"arg": group,
							"subtitle": "fn: Create new entry in '" + group + "'",
						},
					},
				});
			});
	} else {
		jsonArray.push({
			"title": "⚠️ Password Store does not exist",
			"subtitle": passwordStore,
			"valid": false,
		});
	}
	return JSON.stringify({ items: jsonArray });
}
