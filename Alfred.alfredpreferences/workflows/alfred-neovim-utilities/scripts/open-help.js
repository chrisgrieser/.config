#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// JXA version does not work here, since it does not support `-L`
const httpRequest = (/** @type {any} */ url) => app.doShellScript(`curl -sL ${url}`);

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

// Using `open`, since `Application("Finder").open` does sometimes have permission issues
const openFile = (/** @type {string} */ path) => app.doShellScript(`open "${path}"`);

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const repo = argv[0] || "ERROR";
	const vimdocPath = `/tmp/neovim-vimdocs-${repo.replace(/\//g, "_")}.txt`;
	const htmlPath = vimdocPath + ".html";

	// file is already cached
	if (fileExists(htmlPath)) {
		openFile(htmlPath);
		return;
	}

	// get file list
	const branch = JSON.parse(httpRequest(`https://api.github.com/repos/${repo}`)).default_branch;
	const worktreeUrl = `https://api.github.com/repos/${repo}/git/trees/${branch}?recursive=1`;
	const repoFiles = JSON.parse(httpRequest(worktreeUrl)).tree;

	// find the doc file
	const docFile = repoFiles.find((/** @type {{ path: string; }} */ file) => {
		const isDoc = file.path.startsWith("doc/") && file.path.endsWith(".txt");
		const isChangelog = file.path.includes("change");
		const otherCruff =
			repo === "nvim-telescope/telescope.nvim" && file.path.endsWith("secret.txt");
		return isDoc && !isChangelog && !otherCruff;
	});
	if (!docFile) return "No :help found for this repo.";
	const docUrl = `https://raw.githubusercontent.com/${repo}/${branch}/${docFile.path}`;

	// download vimdoc & convert to html
	writeToFile(vimdocPath, httpRequest(docUrl));
	app.doShellScript(`python3 vimdoc2html/vimdoc2html.py "${vimdocPath}"`);
	openFile(htmlPath);
}
