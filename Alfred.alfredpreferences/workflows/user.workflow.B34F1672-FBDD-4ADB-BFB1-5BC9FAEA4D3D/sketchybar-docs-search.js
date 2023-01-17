#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_./]/g, " ") + " " + str + " ";

const workArray = JSON.parse(app.doShellScript('curl -s "https://api.github.com/repos/FelixKratz/SketchyBar/git/trees/documentation?recursive=1"'))
	.tree
	.filter(file => file.path.startsWith("docs/"))
	.map(file => {
		// eslint-disable-next-line no-magic-numbers
		const site = file.path.slice(15, -11); // remove "docs/docs/json/" and "/index.html"
		const parts = site.split("/");
		const parentSite = parts.join("/") + "/";
		const url = "https://felixkratz.github.io/SketchyBar/" + site;
		return {
			"title": site,
			"match": alfredMatcher (site),
			"subtitle": parentSite,
			"arg": url,
			"uid": site,
		};
	});

JSON.stringify({ items: workArray });
