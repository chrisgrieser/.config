#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

const docsURL = "https://api.github.com/repos/rome/tools/git/trees/main?recursive=1";
const baseURL = "https://docs.rome.tools/";
const docPathRegex = /^website\/src\/pages\/(.*)\.mdx?$/i;

const workArray = JSON.parse(app.doShellScript(`curl -sL "${docsURL}"`))
	.tree.filter((/** @type {{ path: string; }} */ file) => docPathRegex.test(file.path))
	.map((/** @type {{ path: string; }} */ entry) => {
		const subsite = entry.path.replace(docPathRegex, "$1");
		const parts = subsite.split("/");
		let displayTitle = parts.pop();
		let category = parts.join("/");
		let url = `${baseURL}/${subsite}`;

		if (subsite.endsWith("index")) {
			displayTitle = category;
			category = "";
			url = `${baseURL}/${subsite.slice(0, -5)}`;
		}

		return {
			title: displayTitle,
			subtitle: category,
			match: alfredMatcher(subsite),
			arg: url,
			uid: subsite,
		};
	});

JSON.stringify({ items: workArray });
