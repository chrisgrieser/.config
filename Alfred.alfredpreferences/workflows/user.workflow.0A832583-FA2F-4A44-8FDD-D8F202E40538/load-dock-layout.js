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
		layout = layout.replace(".plist", "");
		return {
			"title": layout,
			"match": alfredMatcher (layout),
			"arg": layout,
			"uid": layout,
		};
	});

JSON.stringify({ items: layoutArr });

