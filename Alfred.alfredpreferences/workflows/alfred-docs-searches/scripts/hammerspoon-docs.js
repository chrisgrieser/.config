#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

/** @param {string} path */
function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// run `hs.docstrings_json_file` in hammerspoon console to get the docs path
	const hammerspoonDocsJson = "/Applications/Hammerspoon.app/Contents/Resources/docs.json";
	const sites = [];

	const categoryArr = JSON.parse(readFile(hammerspoonDocsJson));

	for (/** @type {{ name: string; desc: string; }} */ const category of categoryArr) {
		const children = category.items.length;
		// categories
		sites.push({
			title: category.name,
			subtitle: `${children} ▪︎ ${category.desc}`,
			match: alfredMatcher(category.name),
			arg: `https://www.hammerspoon.org/docs/${category.name}.html`,
			uid: category.name,
		});

		// category items
		for (/** @type {{ name: string; def: string; desc: string; }} */ const catItem of category.items) {
			const shortdef = catItem.def.split("->")[0].trim();
			const url = `https://www.hammerspoon.org/docs/${category.name}.html#${catItem.name}`;
			sites.push({
				title: catItem.def,
				subtitle: catItem.desc,
				match: alfredMatcher(shortdef),
				arg: url,
				quicklookurl: url,
				uid: `${category.name}_${catItem.name}`,
			});
		}
	}
	sites.push({
		title: "Getting Started",
		match: "getting started examples",
		arg: "https://www.hammerspoon.org/go/",
		uid: "getting-started",
	});

	return JSON.stringify({
		items: sites,
		cache: { seconds: 3600 * 24 * 7 },
	});
}
