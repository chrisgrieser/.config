#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	const requestStr = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
	return requestStr;
}

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const repo = argv[0] || "ERROR";
	const main = `https://api.github.com/repos/${repo}/git/trees/main?recursive=1`;
	const master = `https://api.github.com/repos/${repo}/git/trees/master?recursive=1`;

	// try out branches "main" and "master"
	let branch;
	let repoFiles = JSON.parse(httpRequest(master));
	if (repoFiles.message === "Not Found") {
		repoFiles = JSON.parse(httpRequest(main));
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

	const firstDocfile = docFiles[0].path;
	// https://raw.githubusercontent.com/echasnovski/mini.operators/main/doc/mini-operators.txt
	const docURL = `https://raw.githubusercontent.com/${repo}/${branch}/${firstDocfile}`;

	// download vimdoc & convert to html
	const vimdocPath = `/tmp/neovim-vimdocs-${repo.replace(/\//g, "_")}.txt`;
	writeToFile(vimdocPath, httpRequest(docURL));
	app.doShellScript("python3 ./scripts/vimdoc-to-html.py ");
	app.openLocation(vimdocPath);

	return undefined;
}
