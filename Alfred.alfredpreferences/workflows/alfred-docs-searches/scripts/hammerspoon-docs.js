#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
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
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// run `hs.docstrings_json_file` in hammerspoon console to get the docs path
	const hammerspoonDocsJson = "/Applications/Hammerspoon.app/Contents/Resources/docs.json";
	const workArray = [];
	const categoryArr = JSON.parse(readFile(hammerspoonDocsJson));

	categoryArr.forEach((/** @type {{ items: any[]; name: string; desc: string; }} */ category) => {
		const children = category.items.length;
		// categories
		workArray.push({
			title: category.name,
			subtitle: `${children} ▪︎ ${category.desc}`,
			match: alfredMatcher(category.name),
			arg: `https://www.hammerspoon.org/docs/${category.name}.html`,
			uid: category.name,
		});

		// category items
		category.items.forEach((catItem) => {
			const shortdef = catItem.def.split("->")[0].trim();
			workArray.push({
				title: catItem.def,
				subtitle: catItem.desc,
				match: alfredMatcher(shortdef),
				arg: `https://www.hammerspoon.org/docs/${category.name}.html#${catItem.name}`,
				uid: `${category.name}_${catItem.name}`,
			});
		});
	});
	workArray.push({
		title: "Getting Started",
		match: "getting started examples",
		arg: "https://www.hammerspoon.org/go/",
		uid: "getting-started",
	});

	workArray.reverse(); // so main categories are ranked further above

	return JSON.stringify({ items: workArray });
}
