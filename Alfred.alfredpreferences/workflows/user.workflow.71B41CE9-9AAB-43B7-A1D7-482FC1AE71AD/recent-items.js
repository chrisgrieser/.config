#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

// eslint-disable-next-line quotes
const recentItems = app.doShellScript(`osascript -e 'tell application "System Events" to tell (process 1 where frontmost is true) to set allItems to every menu item of menu of menu item "Recent Items" of menu 1 of menu bar 1'`)
	.split(", ")
	.map(item => item.slice(10).split(" of ")[0]);

const start = recentItems.indexOf("Documents") + 1;
const end = recentItems.indexOf("Servers") - 1;
let i = 0;

// eslint-disable-next-line quotes
const recentFolders = app.doShellScript(`osascript -e 'tell application "System Events" to tell (process "Finder") to set allItems to every menu item of menu of menu item "Recent Folders" of menu "Go" of menu bar 1'`)
	.split(", ")
	.slice(0, -2)
	.map(item => item.slice(10).split(" of ")[0])
	.map(item => {
		i++;
		return { "name": item, "id": i, "type": "d" };
	});

i = 0;
const recentItemsMap = recentItems
	.map(item => {
		// workaround with id necessary, since only file names, but not file paths are
		// saved in the menu, so that the Ids needs to be used to emulate a click in
		// the next applescript step
		i++;
		return { "name": item, "id": i, "type": "f" };
	})
	.slice(start, end)
	.filter(item => !item.name.includes("“"));

const recentAll = [...recentItemsMap, ...recentFolders]
	.map(item => {
		// type: [f]ile, [d]irectory, [p]arent directory
		let revealArg;
		let iconPath;
		if (item.type === "f") {
			revealArg = item.type + (item.id + 1).toString(); // id + 1 = reveal in Finder
			iconPath = "file.png";
		} else {
			revealArg = "p" + item.id.toString();
			iconPath = "folder.png";
		}

		return {
			"title": item.name,
			"uid": item.name,
			"match": alfredMatcher (item.name),
			"mods": {
				"alt": {
					"arg": revealArg,
				},
			},
			"icon": { "path": iconPath },
			"arg": item.type + item.id.toString(),
		};
	});

JSON.stringify({ items: recentAll });
