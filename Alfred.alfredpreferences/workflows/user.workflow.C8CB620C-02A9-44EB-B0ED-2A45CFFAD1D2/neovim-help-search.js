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


const jsonArray = readFile("url-list.txt")
	.split("\n")
	.map(url => {

		const site = url
			.split("/").pop()
			.split(".").shift(); // eslint-disable-line newline-per-chained-call
		let name = url.split("#").pop();
		let subtitle;

		if (url.includes("'")) {
			subtitle = "option";
			name = name.replaceAll("'", "");
		} else if (url.includes(" ")) {
			subtitle = "section";
			url = url.split(" ").shift();
		} else {
			subtitle = site;
		}

		return {
			"title": name,
			"match": alfredMatcher(name),
			"subtitle": subtitle,
			"arg": url,
			"uid": url,
		};
	});

JSON.stringify({ items: jsonArray });
