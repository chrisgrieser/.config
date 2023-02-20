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

const browserConfig = "/Vivaldi/"
const extensionFolder = app.pathTo("home folder") + "/Library/Application Support/${browserConfig}/Default/Extensions"

const jsonArray = app.doShellScript(`find "${extensionFolder}" -name "manifest.json"`)
	.split("\r")
	.map(item => {
		// const name = app.doShellScript("")
		
		return {
			title: item,
			match: alfredMatcher(item),
			// subtitle: item,
			// icon: { type: "fileicon", path: item },
			arg: item,
			uid: item,
		};
	});
JSON.stringify({ items: jsonArray });
