#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const readFile = function (path, encoding) {
	if (!encoding) encoding = $.NSUTF8StringEncoding;
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
};

const jsonArray = [];
const readLaterFile = $.getenv("read_later_file").replace(/^~/, app.pathTo("home folder"));
const workArray = readFile(readLaterFile)
	.trim()
	.split("\n")
	.filter (line => line.startsWith("- [ ] "));


if (workArray.length) {
	workArray.forEach(item => {
		const title = item.split("](")[0].slice(7);
		const url = item.split("](")[1].slice(0, -1);
		jsonArray.push({
			"title": title,
			"subtitle": url,
			"arg": url,
		});
	});
}
else {
	jsonArray.push({
		"title": "Reading List empty.",
		"subtitle": "Press ↵ to open Feedreader.",
		"arg": $.getenv("feedreaderURL"),
	});
}

JSON.stringify({ items: jsonArray });
