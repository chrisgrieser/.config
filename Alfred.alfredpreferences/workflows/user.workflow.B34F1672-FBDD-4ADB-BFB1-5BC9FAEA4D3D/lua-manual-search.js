#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

//------------------------------------------------------------------------------

const luaManualBaseURL = "https://www.lua.org/manual/5.4/";
const ahrefRegex = /.*?"(.*)">(.*?)<.*/;

//------------------------------------------------------------------------------

const luaManual = app.doShellScript(`curl -sL '${luaManualBaseURL}'`)
	.split("\r")
	.filter(line => line.includes("HREF"))
	.map(line => {
		const subsite = line.replace(ahrefRegex, "$1");
		const title = line
			.replace(ahrefRegex, "$2")
			.replaceAll("&ndash; ", "");

		return {
			"title": title,
			"match": alfredMatcher (title),
			"arg": luaManualBaseURL + subsite,
			"uid": subsite,
		};
	});

JSON.stringify({ items: luaManual });
