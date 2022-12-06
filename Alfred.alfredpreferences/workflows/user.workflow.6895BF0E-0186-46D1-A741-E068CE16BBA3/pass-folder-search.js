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
	let passwordStore = argv[0];
	if (passwordStore === "") passwordStore = home + "/.password-store";

	const jsonArray = [];

	if (fileExists(passwordStore)) {
		app.doShellScript(`cd "${passwordStore}" ; find . -type d ! -path "./.git*"`)
			.split("\r")
			.forEach(folder => {
				const isRoot = folder === ".";
				const id = isRoot ? "" : folder.slice(2);
				const displayName = isRoot ? "/ (root)" : folder.slice(2);

				jsonArray.push({
					"title": displayName,
					"match": alfredMatcher(id),
					"arg": id,
					"uid": id,
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
