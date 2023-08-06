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

/** @typedef {object} Formula
 * @property {string} name
 * @property {string[]} dependencies
 * @property {string} caveats
 * @property {string} desc
 * @property {string} homepage
 */

/** @typedef {object} Cask
 * @property {string} token
 * @property {string} desc
 * @property {string} homepage
 */

// INFO https://formulae.brew.sh/docs/api/
// https://docs.brew.sh/Querying-Brew
// these files contain as payload the API response of casks and formulas; they
// are updated on each `brew update`. Since they are effectively caches,
// there is no need create caches on my own
const caskJson = app.pathTo("home folder") + "/Library/Caches/Homebrew/api/cask.jws.json";
const formulaJson = app.pathTo("home folder") + "/Library/Caches/Homebrew/api/formula.jws.json";

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// PERF `ls` quicker than `brew list`
	const installedBrews = app
		.doShellScript("ls -1 /opt/homebrew/Cellar ; ls -1 /opt/homebrew/Caskroom")
		.split("\r");

	if (!fileExists(formulaJson) || !fileExists(caskJson)) app.doShellScript("brew update");

	const casksRaw = JSON.parse(readFile(caskJson)).payload;
	const formulaRaw = JSON.parse(readFile(formulaJson)).payload;

	const caskIcon = "🛢️";
	const formulaIcon = "🍺";

	//───────────────────────────────────────────────────────────────────────────

	/** @type{AlfredItem[]} */
	const casks = JSON.parse(casksRaw).map((/** @type {Cask} */ cask) => {
		const name = cask.token;
		const installedIcon = installedBrews.includes(name) ? " ✅" : "";
		return {
			title: name + installedIcon,
			match: alfredMatcher(name) + cask.desc,
			subtitle: `${caskIcon} · ${cask.desc}`,
			arg: `${name} --cask`,
			mods: {
				// PERF quicker to pass here than to call `brew home` on brew-id
				cmd: {
					subtitle: "⌘: Open " + cask.homepage,
					arg: cask.homepage,
				},
				alt: {
					subtitle: "⌥: Copy " + cask.homepage,
					arg: cask.homepage,
				},
			},
			uid: name,
		};
	});

	/** @type{AlfredItem[]} */
	const formulas = JSON.parse(formulaRaw).map((/** @type {Formula} */ formula) => {
		const name = formula.name;
		const installedIcon = installedBrews.includes(name) ? " ✅" : "";
		const dependencies = formula.dependencies.length > 0 ? ` +${formula.dependencies.length}d ` : "";
		const caveats = formula.caveats || "";
		const caveatIcon = caveats ? " ℹ️ " : "";
		return {
			title: name + installedIcon,
			match: alfredMatcher(name) + formula.desc,
			subtitle: `${formulaIcon}${dependencies}${caveatIcon} · ${formula.desc}`,
			arg: `${name} --formula`,
			text: {
				largetype: caveats,
				copy: caveats,
			},
			mods: {
				// PERF quicker to pass here than to call `brew home` on brew-id
				cmd: {
					subtitle: "⌘: Open " + formula.homepage,
					arg: formula.homepage,
				},
				alt: {
					subtitle: "⌥: Copy " + formula.homepage,
					arg: formula.homepage,
				},
			},
			uid: name,
		};
	});

	console.log(`${formulas.length} formulas, ${casks.length} casks`);
	return JSON.stringify({ items: [...casks, ...formulas] });
}
