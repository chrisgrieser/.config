#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

const baseURL = "https://www.shellcheck.net/wiki/";

//──────────────────────────────────────────────────────────────────────────────

const ahrefRegex = /.*?href='(.*?)'>.*?<\/a>(.*?)(<\/li>|$)/i;
const jsonArr = [];

app.doShellScript(`curl -sL '${baseURL}'`)
	.split("\r")
	.slice(3)
	.forEach(line => {
		const subsite = line.replace(ahrefRegex, "$1");
		if (subsite) return;
		const desc = line.replace(ahrefRegex, "$2").replaceAll("&ndash;", "").trim();
		const url = baseURL + subsite;

		jsonArr.push({
			title: subsite,
			subtitle: desc,
			match: alfredMatcher(subsite) + alfredMatcher(desc),
			arg: url,
			uid: url,
		});
	});

JSON.stringify({ items: jsonArr });
