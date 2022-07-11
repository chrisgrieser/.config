#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const numberOfFilesToDisplay = Number($.getenv("numberOfFilesToDisplay"));

const fileExists = (fpath) => Application("Finder").exists(Path(fpath));
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
ObjC.import("Foundation");
function readFile (path, encoding) {
	if (!encoding) encoding = $.NSUTF8StringEncoding;
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
}

const sessionFile = "~/Library/Application Support/Sublime Text/Local/Session.sublime_session"
	.replace(/^~/, app.pathTo("home folder"));
const recentFilesArr = [];
JSON.parse(readFile(sessionFile)).windows
	.forEach(window => {
		window.file_history.forEach(f => recentFilesArr.push(f));
	});

//------------------------------------------------------------------------------

const workArray = recentFilesArr
	.slice(0, numberOfFilesToDisplay - 1) // to reduce the number of file-existence checks
	.filter (filePath => fileExists(filePath))
	.map(filePath => {
		const pathParts = filePath.split("/");
		const name = pathParts.pop();
		const parentFolder = pathParts.pop();

		return {
			"title": name,
			"subtitle": "▸ " + parentFolder,
			"arg": filePath,
			"type": "file:skipcheck",
			"icon": {
				"type": "fileicon",
				"path": filePath
			},
			"match": alfredMatcher(name)
		};
	});

JSON.stringify({ "items": workArray });

