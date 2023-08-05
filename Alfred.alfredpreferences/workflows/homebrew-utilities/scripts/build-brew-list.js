#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

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

// INFO https://formulae.brew.sh/docs/api/
const home = app.pathTo("home folder");
const caskJson = home + "/Library/Caches/Homebrew/api/cask.jws.json";
const formulaJson = home + "/Library/Caches/Homebrew/api/formula.jws.json";

// PERF `ls` quicker than `brew list`
const installedBrews = app
	.doShellScript("ls -1 /opt/homebrew/Cellar ; ls -1 /opt/homebrew/Caskroom")
	.split("\r");

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	if (!fileExists(formulaJson) || !fileExists(caskJson)) app.doShellScript("brew update");

	const casksRaw = JSON.parse(readFile(caskJson)).payload;

	/** @type{AlfredItem[]} */
	const casks = JSON.parse(casksRaw).map((cask) => {
		const name = cask.token;
		const installedIcon = installedBrews.includes(name) ? " ✅" : "";
		return {
			title: name + installedIcon,
			match: alfredMatcher(name),
			subtitle: `💈 ${cask.desc}`,
			arg: `${name} --cask`,
			mods: {
				cmd: { arg: cask.homepage },
			},
			uid: name,
		};
	});

	const formulaRaw = JSON.parse(readFile(formulaJson)).payload;

	/** @type{AlfredItem[]} */
	const formulas = JSON.parse(formulaRaw).map((formula) => {
		const name = formula.name;
		const installedIcon = installedBrews.includes(name) ? " ✅" : "";
		return {
			title: name + installedIcon,
			match: alfredMatcher(name),
			subtitle: `🍺 ${formula.desc}`,
			arg: `${name} --formula`,
			mods: {
				cmd: { arg: formula.homepage },
			},
			uid: name,
		};
	});

	const all = [...casks, ...formulas];

	return JSON.stringify({ items: all });
}
