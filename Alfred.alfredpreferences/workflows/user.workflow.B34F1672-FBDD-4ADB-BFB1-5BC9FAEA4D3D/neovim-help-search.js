#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.:#]/g, " ")
	+ " " + str + " "
	+ str.replace(/([A-Z])/g, " $1"); // match parts of CamelCase

function readFile (path, encoding) {
	if (!encoding) encoding = $.NSUTF8StringEncoding;
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
}

const fileExists = (filePath) => Application("Finder").exists(Path(filePath));
let jsonArray;
//------------------------------------------------------------------------------

if (fileExists("url-list.txt")) {
	jsonArray = readFile("url-list.txt")
		.split("\n")
		.map(url => {

			const site = url
				.split("/").pop()
				.split(".").shift(); // eslint-disable-line newline-per-chained-call
			let name = url.split("#").pop().replaceAll("'", "");
			const subtitle = site;
			let synonyms = "";

			const hasSynonyms = url.includes(",");
			const isSection = url.includes("\t");
			if (hasSynonyms) {
				synonyms = " " + url.split(",").pop();
				url = url.split(",").shift();
				name = name.split(",").shift();
			} else if (isSection) {
				url = url.split("\t").shift();
				name = name.replace("\t", " ");
			}

			return {
				"title": name + synonyms,
				"match": alfredMatcher(name) + " " + site + " " + alfredMatcher(synonyms),
				"subtitle": subtitle,
				"arg": url,
				"uid": url,
			};
		});
} else {
	jsonArray = {
		"title": "Index missing. Create via ':vim'",
		"valid": false,
	};
}

JSON.stringify({ items: jsonArray });
