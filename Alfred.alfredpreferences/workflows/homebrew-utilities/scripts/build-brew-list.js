#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const caskIcon = "🍺";
const formulaIcon = "🐚";

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

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {

	// INFO https://formulae.brew.sh/docs/api/
	// these files contain as payload the API response of casks and formulas; they
	// are updated on each `brew update`
	const home = app.pathTo("home folder");
	const caskJson = home + "/Library/Caches/Homebrew/api/cask.jws.json";
	const formulaJson = home + "/Library/Caches/Homebrew/api/formula.jws.json";

	// PERF `ls` quicker than `brew list`
	const installedBrews = app
		.doShellScript("ls -1 /opt/homebrew/Cellar ; ls -1 /opt/homebrew/Caskroom")
		.split("\r");

	if (!fileExists(formulaJson) || !fileExists(caskJson)) app.doShellScript("brew update");

	const casksRaw = JSON.parse(readFile(caskJson)).payload;
	const formulaRaw = JSON.parse(readFile(formulaJson)).payload;

	//───────────────────────────────────────────────────────────────────────────

	/** @type{AlfredItem[]} */
	const casks = JSON.parse(casksRaw).map(
		( cask) => {
			const name = cask.token;
			const installedIcon = installedBrews.includes(name) ? " ✅" : "";
			// const dependencies = cask.dependencies.length > 0 ? ` +${cask.dependencies.length} ` : "";
			return {
				title: name + installedIcon,
				match: alfredMatcher(name) + cask.desc,
				subtitle: `${caskIcon} ${cask.desc}`,
				arg: `${name} --cask`,
				mods: {
					// PERF quicker to pass here than to call `brew home` on brew-id
					cmd: { arg: cask.homepage }, 
				},
				uid: name,
			};
		},
	);

	/** @type{AlfredItem[]} */
	const formulas = JSON.parse(formulaRaw).map(
		( formula) => {
			const name = formula.name;
			const installedIcon = installedBrews.includes(name) ? " ✅" : "";
			const dependencies = formula.dependencies.length > 0 ? ` +${formula.dependencies.length} ` : "";
			return {
				title: name + installedIcon,
				match: alfredMatcher(name) + formula.desc,
				subtitle: `${formulaIcon} ${dependencies} ${formula.desc}`,
				arg: `${name} --formula`,
				mods: {
					cmd: { arg: formula.homepage },
				},
				uid: name,
			};
		},
	);

	console.log(`${formulas.length} formulas, ${casks.length} casks`);
	return JSON.stringify({ items: [...casks, ...formulas] });
}
