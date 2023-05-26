#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (/** @type {string} */ str) => str.replace (/[-()_/.]/g, " ") + " " + str + " ";

//------------------------------------------------------------------------------

const sourceURL = "https://api.github.com/repos/obsidianmd/obsidian-developer-docs/git/trees/main?recursive=1";
const baseURL = "https://docs.obsidian.md/"

const workArray = JSON.parse(app.doShellScript(`curl -sL ${sourceURL}`))
	.tree
	.filter((/** @type {{ path: string; }} */ file) => file.path.startsWith("en/") && file.path.endsWith(".md"))
	.map(file => {
		const subsitePath = file.path.slice(5, -3);

		const displayTitle = subsitePath
			.replace(/.*\//, "") // show only file name
			.replaceAll("-", " ");

		const category = subsitePath
			.replace(/(.*)\/.*/, "$1") // only parent
			.replaceAll ("/", " → ") // nicer tree
			.replaceAll("-", " ");

		return {
			"title": displayTitle,
			"subtitle": category,
			"match": alfredMatcher (subsitePath),
			"arg": `https://marcus.se.net/obsidian-plugin-docs/${subsitePath}`,
			"uid": subsitePath,
		};
	});

JSON.stringify({ items: workArray });
