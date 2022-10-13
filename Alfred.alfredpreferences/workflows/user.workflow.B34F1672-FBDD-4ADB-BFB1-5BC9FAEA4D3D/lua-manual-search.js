#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_#.]/g, " ") + " " + str + " ";

//------------------------------------------------------------------------------

const luaManualBaseURL = "https://www.lua.org/manual/5.4/";
const luaWikiBaseURL = "http://lua-users.org/";
const ahrefRegex = /.*?"(.*?)" ?>(.*?)<.*/;
const jsonArr = [];
//------------------------------------------------------------------------------

const rawHTML =
	app.doShellScript(`curl -sL '${luaManualBaseURL}'`)
	+ app.doShellScript(`curl -sL '${luaWikiBaseURL}wiki/LuaDirectory'`);

rawHTML.split("\r")
	.filter(line => line.toLowerCase().includes("href") && !line.includes("css"))
	.forEach(line => {
		const subsite = line.replace(ahrefRegex, "$1");
		const isWiki = subsite.includes("wiki");
		let title = line
			.replace(ahrefRegex, "$2")
			.replaceAll("&ndash; ", "");

		let type = "manual";
		if (isWiki) type = "wiki";
		else if (title.match(/\d/)) type = "manual (chapter)";

		title = title.replace(/^[.0-9]+ /, "");

		let url = isWiki ? luaWikiBaseURL : luaManualBaseURL;
		url += subsite;

		jsonArr.push({
			"title": title,
			"subtitle": type,
			"match": alfredMatcher (title),
			"arg": url,
			"uid": url,
		});
	});

JSON.stringify({ items: jsonArr });
