#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const onlineJSON = (url) => JSON.parse (app.doShellScript("curl -sL \"" + url + "\""));
const pluginList = onlineJSON("https://api.github.com/repos/ohmyzsh/ohmyzsh/git/trees/master?recursive=1")
	.tree
	.map(p => p.path)
	.filter(p => /^plugins\/[^/]+$/.test(p))
	.map (p => p.slice(8));


const jsonArray = [];
pluginList.forEach(plugin => {

	jsonArray.push({
		"title": plugin,
		"subtitle": "",
		"arg": plugin,
	});
});

JSON.stringify({ items: jsonArray });
