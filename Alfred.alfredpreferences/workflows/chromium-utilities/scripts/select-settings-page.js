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
	const allBrowsers = "./data/all-chromium-browser-settings.json";
	const allSettings = JSON.parse(readFile(allBrowsers));
	const browser = $.getenv("browser");

	if (browser !== "chrome") {
		const browserSpecific = `./data/${browser}-specific-settings.json`;
		const specificSettings = JSON.parse(readFile(browserSpecific));
		allSettings.push(...specificSettings);
	}

	// add uid to all items, so Alfred remembers their selection
	for (const page of allSettings) {
		page.uid = page.arg;
	}

	return JSON.stringify({ items: allSettings });
}
