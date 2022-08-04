#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

const recentItems = app.doShellScript(`osascript -e 'tell application "System Events" to tell (process 1 where frontmost is true) to set allItems to every menu item of menu of menu item "Recent Items" of menu 1 of menu bar 1'`)
	.split(", ")
	.filter(item => !item.includes("“"))
	.map(item => item.slice(10).split(" of ")[0]);

const recentItemsMap = recentItems.map(item => {
	const i = {};
	i.id = recentItems.indexOf(item);
	i.name = item;
	return i;
});

recentItemsMap


const start = recentItems.indexOf("Documents") + 1;
const end = recentItems.indexOf("Servers") - 1;

const recentDocs = recentItemsMap
	.slice(start, end)

recentDocs
// 	.map(item => {

// 		return {
// 			"title": item.name,
// 			"match": alfredMatcher (item.name),
// 			"arg": item.id,
// 		};
// 	});

// JSON.stringify({ items: recentDocs });

