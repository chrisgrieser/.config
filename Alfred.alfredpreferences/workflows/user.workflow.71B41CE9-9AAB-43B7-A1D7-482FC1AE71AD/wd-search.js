#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

const defaultFolder = $.getenv("default_folder").replace(/^~/, app.pathTo("home folder"));

const workArray = app.doShellScript (`ls -1 '${defaultFolder}'`)
	.split("\r")
	.map(item => {
		const itemPath = defaultFolder + "/" + item;

		let iconToDisplay;
		if (item.endsWith(".png")) iconToDisplay = { "path": itemPath };
		else {
			iconToDisplay = {
				"type": "fileicon",
				"path": itemPath
			};
		}

		return {
			"title": item,
			"match": alfredMatcher (item),
			"type": "file:skipcheck",
			"arg": itemPath,
			"icon": iconToDisplay,
		};
	});

JSON.stringify({ items: workArray });
