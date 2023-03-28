#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

const luaVersion = $.getenv("lua_version")
const luaManualBaseURL = `https://www.lua.org/manual/${luaVersion}/`;
const luaWikiBaseURL = "http://lua-users.org";

//──────────────────────────────────────────────────────────────────────────────

const ahrefRegex = /.*?href="(.*?)">(.*?)<.*/i;
const jsonArr = [];

const rawHTML =
	app.doShellScript(`curl -sL '${luaManualBaseURL}'`) +
	app.doShellScript(`curl -sL '${luaWikiBaseURL}/wiki/LuaDirectory'`);

rawHTML
	.split("\r")
	.filter(line => line.toLowerCase().includes("href") && !line.includes("css") && !line.includes("IMG"))
	.forEach(line => {
		const subsite = line.replace(ahrefRegex, "$1");
		const isWiki = subsite.includes("wiki");
		let title = line.replace(ahrefRegex, "$2").replaceAll("&ndash; ", "");
		if (title.includes(">")) return;

		let type = "manual";
		if (isWiki) type = "wiki";
		else if (title.match(/\d/)) type = "manual (chapter)";

		title = title.replace(/^[.0-9]+ /, "");

		let url = isWiki ? luaWikiBaseURL : luaManualBaseURL;
		url += subsite;

		jsonArr.push({
			title: title,
			subtitle: type,
			match: alfredMatcher(title),
			arg: url,
			uid: url,
		});
	});

JSON.stringify({ items: jsonArr });
