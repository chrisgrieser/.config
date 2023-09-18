#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const onlineJSON = (/** @type {string} */ url) => JSON.parse(app.doShellScript(`curl -s "${url}"`));

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const repo = argv[0];
	const main = `https://api.github.com/repos/${repo}/git/trees/main?recursive=1`;
	const master = `https://api.github.com/repos/${repo}/git/trees/master?recursive=1`;

	// try out branches "main" and "master"
	let branch;
	let repoFiles = onlineJSON(master);
	if (repoFiles.message === "Not Found") {
		repoFiles = onlineJSON(main);
		branch = "main";
		if (repoFiles.message === "Not Found") return "Default Branch neither 'master' nor 'main'.";
	} else {
		branch = "master";
	}

	// find the doc file
	const docFiles = repoFiles.tree.filter((/** @type {{ path: string; }} */ file) => {
		const isDoc = file.path.startsWith("doc/") && file.path.endsWith(".txt");
		const isChangelog = file.path.includes("change");
		const otherCruff = file.path.includes("secret"); // e.g. telescope
		return isDoc && !isChangelog && !otherCruff;
	});
	if (docFiles.length === 0) return "No :help found for this repo.";

	const firstDocfile = docFiles[0].path
	const docURL = `https://github.com/${repo}/blob/${branch}/${firstDocfile}`;
	app.openLocation(docURL);
}
