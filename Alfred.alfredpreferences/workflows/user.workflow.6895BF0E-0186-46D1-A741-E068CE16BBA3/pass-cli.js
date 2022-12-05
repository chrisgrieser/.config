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
	app.doShellScript(`cd "${passwordStore}" ; find . -name "*.gpg"`)
		.split("\r")
		.forEach(item => {
			item = item.slice(1);

			jsonArray.push({
				"title": item,
				"match": alfredMatcher(item),
				"subtitle": item,
				"type": "file:skipcheck",
				"icon": { "type": "fileicon", "path": item },
				"arg": item,
				"uid": item,
			});
		});
} else {
	jsonArray.push({
		"title": "⚠️ Password Store does not exist",
		"subtitle": passwordStore.replace(/\/Users\/\w+/, "~"),
		"type": "file:skipcheck",
		"valid": false,
	});
}
JSON.stringify({ items: jsonArray });
