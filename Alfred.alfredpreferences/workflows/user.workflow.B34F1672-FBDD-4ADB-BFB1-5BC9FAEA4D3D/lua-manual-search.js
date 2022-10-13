#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_#.]/g, " ") + " " + str + " ";

//------------------------------------------------------------------------------

const luaManualBaseURL = "https://www.lua.org/manual/5.4/";
const luaWikiBaseURL = "http://lua-users.org/wiki/LuaDirectory";
const ahrefRegex = /.*?"(.*)">(.*?)<.*/;
const jsonArr = [];
//------------------------------------------------------------------------------

app.doShellScript(`curl -sL '${luaManualBaseURL}'`)
	.split("\r")
	.filter(line => line.toLowerCase().includes("href") && !line.includes("css"))
	.forEach(line => {
		const subsite = line.replace(ahrefRegex, "$1");
		let title = line
			.replace(ahrefRegex, "$2")
			.replaceAll("&ndash; ", "");
		let type = "";
		if (title.match(/\d/)) type = "chapter";
		title = title.replace(/^[.0-9]+ /, "");

		jsonArr.push({
			"title": title,
			"subtitle": type,
			"match": alfredMatcher (title),
			"arg": luaManualBaseURL + subsite,
			"uid": subsite,
		});
	});

app.doShellScript(`curl -sL '${luaWikiBaseURL}'`)
	.split("\r")
	.filter(line => line.includes("HREF") && !line.includes("css"))
	.forEach(line => {
		const subsite = line.replace(ahrefRegex, "$1");
		let title = line
			.replace(ahrefRegex, "$2")
			.replaceAll("&ndash; ", "");
		let type = "";
		if (title.match(/\d/)) type = "chapter";
		title = title.replace(/^[.0-9]+ /, "");

		jsonArr.push({
			"title": title,
			"subtitle": type,
			"match": alfredMatcher (title),
			"arg": luaManualBaseURL + subsite,
			"uid": subsite,
		});
	});

JSON.stringify({ items: jsonArr });
