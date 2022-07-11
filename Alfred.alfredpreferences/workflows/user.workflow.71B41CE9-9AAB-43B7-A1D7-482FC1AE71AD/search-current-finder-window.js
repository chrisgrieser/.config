#!/usr/bin/env osascript -l JavaScript

// requires `fd`

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
const jsonArray = [];

let folderToSearch;

// Search Finder
const posixPath = (finderWindow) => $.NSURL.alloc.initWithString(finderWindow.target.url()).fileSystemRepresentation;
const currentFinderWindow = posixPath(Application("Finder").finderWindows[0]);
if (currentFinderWindow) folderToSearch = currentFinderWindow;
else {
	jsonArray.push({ "title": "No Finder Window available" });
	JSON.stringify({ items: jsonArray });
}

/* eslint-disable no-multi-str */
const repoArray = app.doShellScript ("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; \
	cd \"" + folderToSearch + "\" ; \
	fd --max-depth=2 --absolute-path --hidden --exclude \"/.git/*\"")
	.split("\r")
	.map(fPath => {
		const parts = fPath.split("/");
		const isFolder = fPath.endsWith("/");
		let name;
		if (isFolder) {
			parts.pop();
			name = parts.pop();
		}
		else name = parts.pop();


		const relativeParentFolder = fPath.slice(folderToSearch.length, -(name.length + 1));

		const fIcon = {
			"type": "fileicon",
			"path": fPath
		};
		// if image, use image content, not file icon
		if (fPath.endsWith(".png")) delete fIcon.type;

		return {
			"title": name,
			"match": alfredMatcher (name),
			"subtitle": relativeParentFolder,
			"type": "file",
			"icon": fIcon,
			"arg": fPath,
			"uid": fPath,
		};
	});

if (!repoArray.length) {
	jsonArray.push({ "title": "No file in the current Folder found." });
	JSON.stringify({ items: jsonArray });
}

JSON.stringify({ items: repoArray });

