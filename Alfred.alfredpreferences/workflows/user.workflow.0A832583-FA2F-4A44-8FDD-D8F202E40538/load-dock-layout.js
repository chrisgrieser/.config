#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

// fill in here
const dockSwitcherDir = $.getenv("dock_switcher_path")
	.replace(/(.*\/).*$/g, "$1");

const layoutArr = app.doShellScript(`ls -1 '${dockSwitcherDir}'`)
	.split("\r")
	.filter()

const jsonArray = [] // fill in here
	// .filter(f => true)
	.map(item => {
		// fill in here
		return {
			"title": item,
			"match": alfredMatcher (item),
			"subtitle": item,
			"type": "file:skipcheck",
			"icon": {
				"type": "fileicon",
				"path": item
			},
			"arg": item,
			"uid": item,
		};
	});

JSON.stringify({ items: jsonArray });

