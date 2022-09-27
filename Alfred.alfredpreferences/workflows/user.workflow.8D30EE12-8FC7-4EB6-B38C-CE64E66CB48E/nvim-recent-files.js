#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.:]/g, " ");

//------------------------------------------------------------------------------

const jsonArray = app.doShellScript("zsh ./nvim-recent-files.sh")
	.split("\r")
	.filter(line => line.startsWith("/")) // remove some buggy output
	.map(filepath => {

		const temp = filepath.split("/");
		const fileName = temp.pop();
		const parentFolder = temp.pop();

		return {
			"title": fileName,
			"match": alfredMatcher (fileName),
			"subtitle": "▸ " + parentFolder,
			"type": "file:skipcheck",
			"icon": {
				"type": "fileicon",
				"path": filepath
			},
			"arg": filepath,
			"uid": filepath,
		};
	});

JSON.stringify({ items: jsonArray });
