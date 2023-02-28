#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	return str.replace(/[-()_.:#/\\;,[\]]/g, " ");
}

//──────────────────────────────────────────────────────────────────────────────

const docsURL = "https://api.github.com/repos/eslint/eslint/git/trees/main?recursive=1";
const baseURL = "https://eslint.org/docs/latest";

const workArray = JSON.parse(app.doShellScript(`curl -s "${docsURL}"`))
	.tree.filter(file => file.path.startsWith("docs/src/rules/") || file.path.startsWith("docs/src/use/"))
	.map(entry => {
		const subsite = entry.path.slice(9, -3);
		const category = subsite.split("/")[0];
		const displayTitle = subsite.split("/")[1];
		const url = `${baseURL}/${subsite}`;

		return {
			title: displayTitle,
			subtitle: category,
			match: alfredMatcher(subsite),
			arg: url,
			uid: subsite,
		};
	});

JSON.stringify({ items: workArray });
