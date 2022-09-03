#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function readFile (path, encoding) {
	if (!encoding) encoding = $.NSUTF8StringEncoding;
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
}

const alfredMatcher = (str) => str.replace (/[-()_:.]/g, " ") + " " + str + " ";
const getEnv = (path) => $.getenv(path).replace(/^~/, app.pathTo("home folder"));

//------------------------------------------------------------------------------

const cssVarRegex = /^\s+(--[\w-]+): (.+);(\s*\/\*\s?(.*)\s?\*\/)?/;

let lineNo = 0;
const sfPath = getEnv("vault_path") + "/.obsidian/themes/Shimmering Focus.css";
const cssVariables = readFile(sfPath)
	.split("\n")
	.map(line => {
		lineNo++;
		return {
			"content": line,
			"number": lineNo
		};
	})
	.filter(line => line.content.match(/^\s+--/))
	.map(line => {
		const varName = line.content.replace(cssVarRegex, "$1");
		const varValue = line.content.replace(cssVarRegex, "$2");
		const varComment = line.content.replace(cssVarRegex, "$3");

		return {
			"title": varName,
			"subtitle": `${varValue}   ${varComment}`,
			"match": alfredMatcher (varName) + alfredMatcher(varValue),
			"uid": varName,
			"arg": line.number,
		};
	});

JSON.stringify({ items: cssVariables });
