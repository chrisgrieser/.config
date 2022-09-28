#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_#.]/g, " ") + " " + str + " ";

//------------------------------------------------------------------------------

const luaManualBaseURL = "https://www.lua.org/manual/5.4/";
const ahrefRegex = /.*?"(.*)">(.*?)<.*/;

//------------------------------------------------------------------------------

const luaManual = app.doShellScript(`curl -sL '${luaManualBaseURL}'`)
	.split("\r")
	.filter(line => line.includes("HREF") && !line.includes("css"))
	.map(line => {
		const subsite = line.replace(ahrefRegex, "$1");
		let title = line
			.replace(ahrefRegex, "$2")
			.replaceAll("&ndash; ", "");
		let type = "";
		if (title.match(/\d/)) type = "chapter";
		title = title.replace(/^[.0-9]+ /, "");

		return {
			"title": title,
			"subtitle": type,
			"match": alfredMatcher (title),
			"arg": luaManualBaseURL + subsite,
			"uid": subsite,
		};
	});

JSON.stringify({ items: luaManual });
