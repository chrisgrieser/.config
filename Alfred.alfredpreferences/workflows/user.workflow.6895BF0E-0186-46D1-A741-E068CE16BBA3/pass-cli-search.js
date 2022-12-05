#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}
const fileExists = (filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────
const passwordStore = $.getenv("password_store").replace(/^~/, app.pathTo("home folder"));
const jsonArray = [];

if (fileExists(passwordStore)) {
	const fdInstalled = app.doShellScript('command -v fd || echo "no"') !== "no";
	const searchCommand = fdInstalled ? 'fd ".*\\.gpg"' : 'find . -name "*.gpg"';

	console.log("searchCommand: " + searchCommand);

	app.doShellScript(`cd "${passwordStore}" ; ${searchCommand}`)
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
			});
		});
} else {
	jsonArray.push({
		"title": "⚠️ Password Store does not exist",
		"subtitle": passwordStore.replace(/\/Users\/\w+/, "~"),
		"valid": false,
	});
}
JSON.stringify({ items: jsonArray });
