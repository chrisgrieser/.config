#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_./]/g, " ") + " " + str + " ";

const workArray = JSON.parse(app.doShellScript('curl -s "https://api.github.com/repos/espanso/website/git/trees/main?recursive=1"'))
	.tree
	.filter(file => /^docs\/.*\.mdx?$/.test(file.path))
	.filter(file => !file.path.includes("/_"))
	.map(file => {
		const site = file.path
			.slice(5) // remove "docs/"
			.replace(/\.mdx?$/, ""); // remove file extension
		const parts = site.split("/");
		const subsite = parts.pop().replaceAll("-", " ");
		const parentsite = parts.join("/");
		return {
			"title": subsite,
			"subtitle": parentsite,
			"match": alfredMatcher (site),
			"arg": site,
			"uid": site,
		};
	});

JSON.stringify({ items: workArray });
