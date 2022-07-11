#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
const jsonArray = [];

// casks
app.doShellScript ("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH; brew list --casks -1")
	.split("\r")
	.forEach(item => {
		jsonArray.push({
			"title": item,
			"match": alfredMatcher (item),
			"subtitle": "cask",
			"arg": item,
		});
	});

// formulae (installed on request)
app.doShellScript ("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH; brew leaves --installed-on-request")
	.split("\r")
	.forEach(item => {
		jsonArray.push({
			"title": item,
			"match": alfredMatcher (item),
			"subtitle": "formula",
			"mods": { "cmd": { "arg": item } },
			"arg": item,
		});
	});

// MAS apps
app.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; mas list")
	.split("\r")
	.forEach(item => {
		item = item.replace (/\d+ +([\w ]+?) +\(.*/, "$1").trim();
		jsonArray.push({
			"title": item,
			"match": item,
			"subtitle": "Mac App Store",
			"arg": "/Applications/" + item + ".app",
			"mods": {
				"cmd": {
					"arg": false,
					"subtitle": "⛔️ Invalid for MAS app."
				}
			},
		});
	});

// direct return
JSON.stringify({ items: jsonArray });
