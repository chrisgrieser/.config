#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
ObjC.import("Foundation");
function readFile (path, encoding) {
	if (!encoding) encoding = $.NSUTF8StringEncoding;
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
}

// run `hs.docstrings_json_file` in hammerspoon console to get the docs path
const hammerspoonDocsJson = "/Applications/Hammerspoon.app/Contents/Resources/docs.json";

const workArray = [];

const categoryArr = JSON.parse(readFile(hammerspoonDocsJson));
categoryArr.forEach(category => {
	const children = category.items.length;
	// categories
	workArray.push({
		"title": category.name,
		"subtitle": `${children} ▪︎ ${category.desc}`,
		"match": alfredMatcher (category.name),
		"arg": `https://www.hammerspoon.org/docs/${category.name}.html`,
		"uid": category.name,
		"mods": {
			"alt": {
				"arg": category.name,
				"subtitle": `⌘: Copy ${category.name}`
			},
		},
	});

	// categories items
	category.items.forEach(catItem => {
		const shortdef = catItem.def.split("->")[0].trim();
		workArray.push({
			"title": catItem.def,
			"subtitle": catItem.desc,
			"match": alfredMatcher (shortdef),
			"arg": `https://www.hammerspoon.org/docs/${category.name}.html#${catItem.name}`,
			"uid": `${category.name}_${catItem.name}`,
			"mods": {
				"alt": {
					"arg": shortdef,
					"subtitle": `⌘: Copy ${shortdef}`
				},
			},

		});
	});
});

JSON.stringify({ items: workArray });
