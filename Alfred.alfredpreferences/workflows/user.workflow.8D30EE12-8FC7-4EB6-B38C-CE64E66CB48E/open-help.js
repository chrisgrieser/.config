#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	const onlineJSON = (url) => JSON.parse(app.doShellScript(`curl -s "${url}"`));

	//───────────────────────────────────────────────────────────────────────────

	const repo = argv.join("").replace(/https:\/\/github\.com\/(.+?\/.*)/, "$1");

	const apiUrl = "https://api.github.com/repos/" + repo + "git/trees/";

	let repoFiles = onlineJSON(apiUrl + "master");
	if (repoFiles.message) repoFiles = onlineJSON(apiUrl + "main");
	if (repoFiles.message) return "Default Branch neither 'master' nor 'main'.";

	const docFiles = repoFiles.tree.filter()

}
