#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;

// read local homebrew files
const casks = app.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; brew casks")
	.split("\r")
	.map (line => line + " --cask");
const formulae = app.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; brew formulae")
	.split("\r")
	.map (line => line + " --formula");
const searchResults = [...casks, ...formulae].map(brew => {
	const resultName = brew.split(" --")[0];
	const resultType = brew.split(" --")[1];
	const betterMatching = resultName.replaceAll ("-", " ") + " " + resultName;
	return {
		"title": resultName,
		"subtitle": resultType,
		"arg": brew,
		"match": betterMatching,
		"mods": { "cmd": { "arg": resultName } },
	};
});

// direct return
JSON.stringify({ items: searchResults });
