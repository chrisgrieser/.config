#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

//------------------------------------------------------------------------------

const hsFunctions = app.doShellScript('grep -RSEo "function ?\\w+" --line-number --exclude-dir=Spoons "$HOME/dotfiles/hammerspoon" ')
	.split("\r")
	.map(result => {
		const file = result.split(":")[0];
		const fileName = file.split("/").pop().slice(0, -4);
		const line = result.split(":")[1];
		const functionName = result.split(":")[2].slice(9);

		return {
			"title": functionName,
			"subtitle": fileName,
			"match": alfredMatcher (`${fileName} ${functionName}`),
			"arg": `${file}:${line}`,
			"uid": `${file}-${functionName}`,
		};
	});

JSON.stringify({ items: hsFunctions });
