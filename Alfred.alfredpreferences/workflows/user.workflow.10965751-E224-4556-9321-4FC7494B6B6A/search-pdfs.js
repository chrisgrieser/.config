#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

const folderToSearch = $.getenv("pdf_folder").replace(/^~/, app.pathTo("home folder"));

/* eslint-disable no-multi-str */
const jsonArray = app.doShellScript ("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; \
	cd '" + folderToSearch + "' ; \
	fd --type=file --absolute-path")
	.split("\r")
	.map(fPath => {

		const parts = fPath.split("/");
		const name = parts.pop();
		const relativeParentFolder = parts.pop();

		return {
			"title": name,
			"match": alfredMatcher (name),
			"subtitle": "▸ " + relativeParentFolder,
			"type": "file:skipcheck",
			"arg": fPath,
			"uid": fPath,
		};
	});

JSON.stringify({ items: jsonArray });
