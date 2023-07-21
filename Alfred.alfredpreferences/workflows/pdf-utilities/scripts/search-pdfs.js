#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

const folderToSearch = $.getenv("pdf_folder").replace(/^~/, app.pathTo("home folder"));

// prettier-ignore
const jsonArray = app.doShellScript(`cd '${folderToSearch}'; fd --type=file --absolute-path`)
	.split("\r")
	.map(fPath => {
		const parts = fPath.split("/");
		const name = parts.pop();
		const relativeParentFolder = parts.pop();

		return {
			title: name,
			match: alfredMatcher(name),
			subtitle: "▸ " + relativeParentFolder,
			type: "file:skipcheck",
			arg: fPath,
			uid: fPath,
		};
	});

JSON.stringify({ items: jsonArray });
