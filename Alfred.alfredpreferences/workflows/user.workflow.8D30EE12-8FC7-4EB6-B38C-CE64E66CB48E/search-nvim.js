#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-/()_.:]/g, " ")
	+ " " + str + " "
	+ str.replace(/([A-Z])/g, " $1"); // match parts of CamelCase

//------------------------------------------------------------------------------

const searchURL = "https://nvim.sh/s";
const baseURL = "https://github.com/";

const jsonArray = app.doShellScript(`curl -sL '${searchURL}'`)
	.split("\r")
	.slice(2)
	.map(line => {
		const parts = line.split(/ {2,}/);
		const repo = parts[0];
		const name = repo.split("/")[1];
		const stars = parts[1];
		// const updated = parts[2];
		// const openIssues = parts[3];
		const desc = parts[4];

		return {
			"title": name,
			"match": alfredMatcher (repo),
			"subtitle": `★ ${stars}  ${desc}`,
			"arg": `${baseURL}${repo}`,
			"uid": repo,
		};
	});

JSON.stringify({ items: jsonArray });

