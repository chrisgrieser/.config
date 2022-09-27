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

		const fileName = filepath.split("/").pop();
		const twoParents = filepath.replace(/.*\/(.*\/.*)\/.*$/, "$1");

		return {
			"title": fileName,
			"match": alfredMatcher (fileName),
			"subtitle": "▸ " + twoParents,
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
