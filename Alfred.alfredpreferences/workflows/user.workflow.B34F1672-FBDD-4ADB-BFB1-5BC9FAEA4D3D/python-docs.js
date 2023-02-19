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

const pythonVersion = "3.11"
const docsURL = "https://api.github.com/repos/python/cpython/git/trees/main?recursive=1"
const baseURL = `https://docs.python.org/${pythonVersion}`

const workArray = JSON.parse(app.doShellScript(`curl -s "${docsURL}"`))
	.tree
	.filter(file => file.path.match(/^Doc\/.*\.rst/))
	.map(file => {

		return {
			"title": file,
			"match": alfredMatcher (file),
			"arg": `${baseURL}/${file}`,
			"uid": file,
		};
	});

JSON.stringify({ items: workArray });
