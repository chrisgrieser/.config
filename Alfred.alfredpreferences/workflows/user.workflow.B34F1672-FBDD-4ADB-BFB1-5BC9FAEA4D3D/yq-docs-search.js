#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

const docsURL = "https://api.github.com/repos/mikefarah/yq/git/trees/master?recursive=1";
const baseURL = "https://mikefarah.gitbook.io/yq/";

const workArray = JSON.parse(app.doShellScript(`curl -s "${docsURL}"`))
	.tree.filter(file => /^pkg\/yqlib\/doc\/.*\.md/.test(file.path))
	.map(entry => {
		const subsite = entry.path.slice(4, -4);
		const category = subsite.split("/")[0];
		const displayTitle = subsite.split("/")[1];
		const url = `${baseURL}/${subsite}.html`

		return {
			title: displayTitle,
			subtitle: category,
			match: alfredMatcher(subsite),
			arg: url,
			uid: subsite,
		};
	});

JSON.stringify({ items: workArray });
