#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const browser = $.getenv("browser");
	const browserVars = JSON.parse(readFile("./data/browser-vars.json"));

	const allSettings = JSON.parse(readFile("./data/all-chromium-browser-settings.json"));
	allSettings.push(...browserVars.settingsPages[browser]);
	const iconPath = browserVars.appIcon[browser];
	const uri = browserVars.uri[browser];

	for (const page of allSettings) {
		page.arg = page.arg.replace(/^chrome:\/\//, uri);
		page.uid = page.arg; // uid = Alfred remembers their selection
		page.icon = { path: iconPath };
	}

	return JSON.stringify({ items: allSettings });
}
