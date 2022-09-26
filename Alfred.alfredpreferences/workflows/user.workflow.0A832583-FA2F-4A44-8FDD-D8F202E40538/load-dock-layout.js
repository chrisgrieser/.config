#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

// fill in here
const dockSwitcherDir = $.getenv("dock_switcher_path")
	.replace(/^~/, app.pathTo("home folder"))
	.replace(/(.*\/).*$/, "$1");

const layoutArr = app.doShellScript(`ls -1 '${dockSwitcherDir}'`)
	.split("\r")
	.filter(item => item.endsWith(".plist"))
	.map(layout => {
		const name = layout.replace(".plist", "");
		return {
			"title": name,
			"subtitle": "↵: load",
			"match": alfredMatcher (name),
			"arg": name,
			"uid": name,
		};
	});

JSON.stringify({ items: layoutArr });

