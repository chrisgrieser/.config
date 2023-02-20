#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

const browserConfig = "/Vivaldi/"; // lead the surrounding // for automation purposes
const extensionFolder = app.pathTo("home folder") + `/Library/Application Support/${browserConfig}/Default/Extensions`;

const jsonArray = app
	.doShellScript(`find "${extensionFolder}" -name "manifest.json"`)
	.split("\r")
	.map(manifestPath => {
		const id = manifestPath.replace(/.*Extensions\/(\w+)\/.*/, "$1") 
		const manifest = JSON.parse(readFile(manifestPath));
		let name = manifest.name;
		const description = manifest.description.startsWith("__MSG_") ? "" : manifest.description;
		if (name.startsWith("__MSG_") && manifest.short_name) name = manifest.short_name;

		return {
			title: name,
			subtitle: description,
			match: alfredMatcher(name),
			// icon: { type: "fileicon", path: item },
			arg: id,
			uid: id,
		};
	});
JSON.stringify({ items: jsonArray });
