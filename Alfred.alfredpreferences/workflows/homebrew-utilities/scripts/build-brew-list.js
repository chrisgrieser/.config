#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const home = app.pathTo("home folder");

//──────────────────────────────────────────────────────────────────────────────

const alfredMatcher = (/** @type {string} */ str) => str.replaceAll("-", " ") + " " + str + " ";

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

// INFO Not using API, since it's too slow and only has the benefit of providing
// descriptions which I can live without
// https://formulae.brew.sh/docs/api/
const caskTxt = home + "/Library/Caches/Homebrew/api/cask_names.txt";
const formulaTxt = home + "/Library/Caches/Homebrew/api/formula_names.txt";
const caskJson = home + "/Library/Caches/Homebrew/api/cask.json";

const installedBrews = app
	.doShellScript("brew list | cat") // piping to cat eliminates decorative lines
	.split("\r");

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	if (!(fileExists(formulaTxt) && fileExists(caskTxt))) app.doShellScript("brew update");

	/** @type{AlfredItem[]} */
	const casks = readFile(caskTxt)
		.split("\n")
		.map((name) => {
			const installedIcon = installedBrews.includes(name) ? " ✅" : "";
			return {
				title: name + installedIcon,
				match: alfredMatcher(name),
				subtitle: "cask",
				arg: `${name} --cask`,
				uid: name,
			};
		});

	/** @type{AlfredItem[]} */
	const formula = readFile(formulaTxt)
		.split("\n")
		.map((name) => {
			const installedIcon = installedBrews.includes(name) ? " ✅" : "";
			return {
				title: name + installedIcon,
				match: alfredMatcher(name),
				subtitle: "formula",
				arg: `${name} --formula`,
				uid: name,
			};
		});
	const all = [...casks, ...formula];

	return JSON.stringify({ items: all });
}
