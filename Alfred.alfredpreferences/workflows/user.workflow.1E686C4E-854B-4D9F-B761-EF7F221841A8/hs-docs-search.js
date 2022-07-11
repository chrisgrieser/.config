#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

const workArray = JSON.parse(app.doShellScript('curl -s "https://api.github.com/repos/Hammerspoon/hammerspoon.github.io/git/trees/master?recursive=1"'))
	.tree
	.filter(file => file.path.startsWith("docs/hs"))
	.map(file => {
		const subsite = file.path.slice(5, -5); // remove "/docs" and ".html"
		return {
			"title": subsite,
			"match": alfredMatcher (subsite),
			"arg": `https://www.hammerspoon.org/docs/${subsite}.html`,
			"uid": subsite,
		};
	});

// individual pages
workArray.push({
	"title": "Getting Started",
	"match": "getting started examples",
	"arg": "https://www.hammerspoon.org/go/",
	"uid": "getting-started",
});
workArray.push({
	"title": "Hammerspoon Keymaps",
	"match": "keymaps keycode hotkey",
	"arg": "https://www.hammerspoon.org/docs/hs.keycodes.html#map",
	"uid": "keymaps",
});

JSON.stringify({ items: workArray });
