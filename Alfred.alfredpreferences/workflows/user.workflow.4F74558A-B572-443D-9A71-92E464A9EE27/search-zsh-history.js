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

//------------------------------------------------------------------------------

const historyPath = $.getenv("history_path").replace(/^~/, app.pathTo("home folder"));
const historyItems = readFile("/Users/chrisgrieser/.zshrc")
	.trim()
	.split("/n")
	.filter(item => item.length !== 0)
	.map(item => {
		const command = item; // eslint-disable-line no-magic-numbers
		return {
			"title": command,
			"match": alfredMatcher (command),
			"subtitle": item,
			"arg": command,
		};
	});

JSON.stringify({ items: historyItems });
