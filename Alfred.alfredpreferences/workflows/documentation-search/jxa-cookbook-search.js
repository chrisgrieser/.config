#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────


// curl https://github.com/JXA-Cookbook/JXA-Cookbook/wiki | grep 'href="/JXA-Cookbook/JXA-Cookbook/wiki/'

const wikiURL = "https://github.com/JXA-Cookbook/JXA-Cookbook/wiki";
const ahrefRegex = /.*?href="(.*?)">(.*?)<.*/i;

const workArray = app.doShellScript(`curl -sL "${wikiURL}"`)
	.split("\r")
	.filter(line => line.includes("href"))
	.map(line => {
		const subsite = line.replace(ahrefRegex, "$1");
		const parts = subsite.split("/");
		const displayTitle = parts.pop();
		const url = `${wikiURL}/${subsite}`;

		return {
			title: displayTitle,
			match: alfredMatcher(subsite),
			arg: url,
			uid: subsite,
		};
	});

JSON.stringify({ items: workArray });
