#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

const docsURL = "https://api.github.com/repos/eslint/eslint/git/trees/main?recursive=1";
const baseURL = "https://eslint.org/docs/latest";
const docPathRegex = /^docs\/src\/(?:rules|use)\/(.*)\.md$/i;

const workArray = JSON.parse(app.doShellScript(`curl -s "${docsURL}"`))
	.tree.filter(file => docPathRegex.test(file.path))
	.map(entry => {
		const subsite = entry.path.slice(9, -3);
		const parts = subsite.split("/");
		const displayTitle = parts.pop();
		const category = parts.join("/");
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
