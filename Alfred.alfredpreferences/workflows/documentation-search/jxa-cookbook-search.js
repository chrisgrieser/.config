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
const baseURL = "https://github.com";

const ahrefRegex = /.*?href="(.*?)">(.*?)<.*/i;

const workArray = app
	.doShellScript(`curl -sL "${wikiURL}"`)
	.split("\r")
	.filter(line => line.includes('a class="internal present"'))
	.slice(3) // remove ToC, FOreword and duplicate conventions
	.map(line => {
		const subsite = line.replace(ahrefRegex, "$1");
		const title = line.replace(ahrefRegex, "$2");
		const url = `${baseURL}${subsite}`;
		const isSubheading = subsite.includes("#")
		const 

		return {
			title: title,
			subtitle: category,
			match: alfredMatcher(subsite),
			arg: url,
			uid: subsite,
		};
	});

JSON.stringify({ items: workArray });
