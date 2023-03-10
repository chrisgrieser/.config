#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_./]/g, " ") + " " + str + " ";

const workArray = JSON.parse(app.doShellScript('curl -s "https://api.github.com/repos/pqrs-org/gh-pages-karabiner-elements.pqrs.org/git/trees/main?recursive=1"'))
	.tree
	.filter(file => file.path.startsWith("docs/docs/json/") && file.path.endsWith("/index.html"))
	.map(file => {
		// eslint-disable-next-line no-magic-numbers
		const site = file.path.slice(15, -11); // remove "docs/docs/json/" and "/index.html"
		const parts = site.split("/");
		const subsite = parts.pop();
		const parentSite = parts.join("/") + "/";
		const url = "https://karabiner-elements.pqrs.org/docs/json/" + site;
		return {
			"title": subsite,
			"match": alfredMatcher (site),
			"subtitle": parentSite,
			"arg": url,
			"uid": site,
		};
	});

JSON.stringify({ items: workArray });
