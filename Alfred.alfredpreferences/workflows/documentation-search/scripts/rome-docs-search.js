#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

const docsURL = "https://api.github.com/repos/rome/tools/git/trees/main?recursive=1";
const baseURL = "https://docs.rome.tools/";
const docPathRegex = /^website\/src\/pages\/(.*)\.mdx?$/i;

const workArray = JSON.parse(app.doShellScript(`curl -sL "${docsURL}"`))
	.tree.filter((/** @type {{ path: string; }} */ file) => docPathRegex.test(file.path))
	.map((/** @type {{ path: string; }} */ entry) => {
		let subsite = entry.path.replace(docPathRegex, "$1");
		if (subsite.endsWith("index")) subsite = subsite.slice(0, -5);
		const parts = subsite.split("/");
		const displayTitle = parts.pop();
		const category = parts.join("/");
		let url = `${baseURL}/${subsite}`;

		return {
			title: displayTitle,
			subtitle: category,
			match: alfredMatcher(subsite),
			arg: url,
			uid: subsite,
		};
	});

JSON.stringify({ items: workArray });
