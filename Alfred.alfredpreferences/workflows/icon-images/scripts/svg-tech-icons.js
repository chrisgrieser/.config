#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const apiUrl1 = "https://api.github.com/repos/vscode-icons/vscode-icons/git/trees/master?recursive=1"
	const apiUrl2 = "https://api.github.com/repos/material-extensions/vscode-material-icon-theme/git/trees/main?recursive=1"

	const response1 = httpRequest(apiUrl1);
	if (!response1) return JSON.stringify({ items: [{ title: "Error: No results", valid: false }] });
	const tree1 = JSON.parse(response1).tree;
	/** @type {AlfredItem[]} */
	const items1 = tree1.flatMap((/** @type {{path: string}} */ item) => {
		const [_, name] = item.path.match(/^icons\/(.*)\.svg$/) || []
		if (!name) return [];
		const url = `https://raw.githubusercontent.com/vscode-icons/vscode-icons/master/icons/${name}.svg`;
		return {
			title: name,
			subtitle: "vscode-icons",
			arg: url,
		};
	});

	const response2 = httpRequest(apiUrl1);
	if (!response2) return JSON.stringify({ items: [{ title: "Error: No results", valid: false }] });
	const tree2 = JSON.parse(response2).tree;
	/** @type {AlfredItem[]} */
	const items2 = tree2.flatMap((/** @type {{path: string}} */ item) => {
		const [_, name] = item.path.match(/^icons\/(.*)\.svg$/) || []
		if (!name) return [];
		const url = `https://raw.githubusercontent.com/material-extensions/vscode-material-icon-theme/master/icons/${name}.svg`;
		return {
			title: name,
			subtitle: "material-icons",
			arg: url,
		};
	});

	return JSON.stringify({
		items: [...items1, items2],
		// cache: { seconds: 60 * 60 * 24 * 7, loosereload: true }, // 1 week
	});
}

