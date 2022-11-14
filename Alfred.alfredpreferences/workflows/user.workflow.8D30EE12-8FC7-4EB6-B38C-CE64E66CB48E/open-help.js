#!/usr/bin/env osascript -l JavaScript
function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	const onlineJSON = (url) => JSON.parse(app.doShellScript(`curl -s "${url}"`));

	//───────────────────────────────────────────────────────────────────────────

	const repo = argv.join("");
	const apiUrl = "https://api.github.com/repos/" + repo + "/git/trees/";
	const main = apiUrl + "main?recursive=1";
	const master = apiUrl + "master?recursive=1";

	// try out branches "main" and "master"
	let repoFiles = onlineJSON(master);
	let branch = "master";
	if (repoFiles.message) {
		repoFiles = onlineJSON(main);
		branch = "main";
	}
	if (repoFiles.message) return "Default Branch neither 'master' nor 'main'.";

	const docFiles = repoFiles.tree.filter(file => {
		const isDoc = file.path.startsWith("doc/");
		const isChangelog = file.path.includes("change");
		const otherCruff = file.path.includes("secret"); // e.g. telescope
		return isDoc && !isChangelog && !otherCruff;
	});

	let docFile;
	let docURL;

	if (docFiles.length === 0) {
		docURL = "https://github.com/" + repo + "#readme";
	} else {
		docFile = docFiles[0].path;
		docURL = `https://github.com/${repo}/blob/${branch}/${docFile}`;
	}

	app.openLocation(docURL);
}
