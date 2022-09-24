#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

function readFile (path, encoding) {
	if (!encoding) encoding = $.NSUTF8StringEncoding;
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
}

//------------------------------------------------------------------------------

const VAR = $.getenv("VAR").replace(/^~/, app.pathTo("home folder"));

const jsonArray = []
	.map(item => {

		return {
			"title": item,
			"match": alfredMatcher (item),
			"subtitle": item,
			"type": "file:skipcheck",
			"icon": {
				"type": "fileicon",
				"path": item
			},
			"arg": item,
			"uid": item,
		};
	});

JSON.stringify({ items: jsonArray });
