#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_./]/g, " ") + " " + str + " ";

const workArray = JSON.parse(app.doShellScript('curl -s "https://api.github.com/repos/FelixKratz/SketchyBar/git/trees/documentation?recursive=1"'))
	.tree
	.filter(file => file.path.startsWith("docs/") && file.path.endsWith(".md"))
	.map(file => {
		const site = file.path.slice(5, -3); // remove "docs/" and ".md"
		const parts = site.split("/");
		let subsite = parts.pop();
		subsite = subsite.charAt(0).toUpperCase() + subsite.slice(1); // capitalize
		const parentSite = parts.join("/");
		const url = "https://felixkratz.github.io/SketchyBar/" + site;
		return {
			"title": subsite,
			"match": alfredMatcher (site),
			"subtitle": parentSite,
			"arg": url,
			"uid": site,
		};
	});

JSON.stringify({ items: workArray });
