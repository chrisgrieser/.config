#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-/()_.:]/g, " ")
	+ " " + str + " "
	+ str.replace(/([A-Z])/g, " $1"); // match parts of CamelCase

//------------------------------------------------------------------------------

const searchURL = "https://raw.githubusercontent.com/vimcolorschemes/vimcolorschemes/main/database/seed.json";

const jsonArray = JSON.parse(app.doShellScript(`curl -sL '${searchURL}'`))
	.map(theme => {
		const repo = theme.githubURL.replace(/.*\/(?=.*\/)/, "");
		return {
			"title": theme.name,
			"match": alfredMatcher (theme.name),
			"subtitle": `★ ${theme.stargazersCount}   ${theme.description}`,
			"arg": repo,
			"uid": repo,
		};
	});

JSON.stringify({ items: jsonArray });

