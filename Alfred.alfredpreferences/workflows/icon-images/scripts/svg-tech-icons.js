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
	// CONFIG
	const iconRepos = {
		vscode: { name: "vscode-icons/vscode-icons", branch: "master" },
		material: { name: "material-extensions/vscode-material-icon-theme", branch: "main" },
		"simple-icons": { name: "simple-icons/simple-icons", branch: "develop" },
	};
	// INFO svgs are assumed to be `./icons/*.svg`
	//---------------------------------------------------------------------------

	/** @type {AlfredItem[]} */
	const items = [];

	for (const [iconGroup, repo] of Object.entries(iconRepos)) {
		const apiUrl = `https://api.github.com/repos/${repo.name}/git/trees/${repo.branch}?recursive=1`;
		const response = httpRequest(apiUrl);
		const tree = JSON.parse(response).tree;
		tree.forEach((/** @type {{path: string}} */ item) => {
			const iconName = item.path.match(/^icons\/(.*)\.svg$/)?.[1];
			if (!iconName) return;
			items.push({
				title: iconName.replaceAll("file_type_", ""),
				subtitle: iconGroup,
				arg: `https://raw.githubusercontent.com/${repo.name}/${repo.branch}/icons/${iconName}.svg`,
			});
		});
	}

	return JSON.stringify({
		items: items,
		cache: { seconds: 60 * 60 * 24 * 7, loosereload: true }, // 1 week
	});
}
