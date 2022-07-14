#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";

const workArray = JSON.parse(app.doShellScript('curl -s "https://api.github.com/repos/git/git/git/trees/master?recursive=1"'))
	.tree
	.filter(file => file.path.startsWith("Documentation/"))
	.filter(file => !file.path.includes("/RelNotes/"))
	.map(file => {
		const subsite = file.path
			.slice(14) // eslint-disable-line no-magic-numbers
			.replace(/\.\w+$/, ""); // remove extension

		const displayTitle = subsite.replaceAll("-", " ");

		return {
			"title": displayTitle,
			"match": alfredMatcher (subsite),
			"arg": `https://git-scm.com/docs/${subsite}`,
			"uid": subsite,
		};
	});

JSON.stringify({ items: workArray });
