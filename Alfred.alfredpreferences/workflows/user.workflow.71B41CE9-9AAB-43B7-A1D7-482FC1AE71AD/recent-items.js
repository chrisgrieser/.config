#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

const recentItems = app.doShellScript(`osascript -e 'tell application "System Events" to tell (process 1 where frontmost is true) to set allItems to every menu item of menu of menu item "Recent Items" of menu 1 of menu bar 1'`)
	.split(", ")
	.map(item => item.slice(10).split(" of ")[0]);

const start = recentItems.indexOf("Documents") + 1;
const end = recentItems.indexOf("Servers") - 1;

// workaround with id necessary, since only file names, but not file paths are
// saved in the menu, so that the Ids needs to be used to emulate a click in
// the next applescript step

let i = 0;
const recentItemsMap = recentItems
	.map(item => {
		i++;
		return { name: item, id: i };
	})
	.slice(start, end)
	.filter(item => !item.name.includes("“"))
	.map(item => {
		return {
			"title": item.name,
			"match": alfredMatcher (item.name),
			"arg": item.id,
			"mods": { "alt": { "arg": item.id + 1 } }, // id + 1 = reveal in Finder
		};
	});

JSON.stringify({ items: recentItemsMap });

