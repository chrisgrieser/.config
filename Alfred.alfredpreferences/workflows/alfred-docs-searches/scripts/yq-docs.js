#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const docsURL = "https://api.github.com/repos/mikefarah/yq/git/trees/master?recursive=1";
const baseURL = "https://mikefarah.gitbook.io/yq";
const docPathRegex = /^pkg\/yqlib\/doc\/(.*)\.md$/i;

const workArray = JSON.parse(app.doShellScript(`curl -s "${docsURL}"`))
	.tree.filter((file) => docPathRegex.test(file.path) && !file.path.includes("/headers/"))
	.map((/** @type {{ path: string; }} */ entry) => {
		const subsite = entry.path.replace(docPathRegex, "$1");
		const category = subsite.split("/")[0];
		const displayTitle = subsite.split("/")[1];
		const url = `${baseURL}/${subsite}`;

		return {
			title: displayTitle,
			subtitle: category,
			arg: url,
			uid: subsite,
		};
	});

JSON.stringify({ items: workArray });
