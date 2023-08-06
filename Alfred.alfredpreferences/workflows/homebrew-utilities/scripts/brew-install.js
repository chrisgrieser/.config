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
// MAIN DATA
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

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// 1. MAIN DATA
	// DOCS https://formulae.brew.sh/docs/api/ & https://docs.brew.sh/Querying-Brew
	// these files contain as payload the API response of casks and formulas; they
	// are updated on each `brew update`. Since they are effectively caches,
	// there is no need create caches on my own
	const caskJson = app.pathTo("home folder") + "/Library/Caches/Homebrew/api/cask.jws.json";
	const formulaJson = app.pathTo("home folder") + "/Library/Caches/Homebrew/api/formula.jws.json";
	if (!fileExists(formulaJson) || !fileExists(caskJson)) app.doShellScript("brew update");
	// yes, the data must be parsed twice, since that is how the cache is saved
	// by homebrew
	const casksData = JSON.parse(JSON.parse(readFile(caskJson)).payload);
	const formulaData = JSON.parse(JSON.parse(readFile(formulaJson)).payload);

	// 2. INSTALL DATA
	// PERF `ls` quicker than `brew list` or the API
	const installedBrews = app
		.doShellScript("ls -1 /opt/homebrew/Cellar ; ls -1 /opt/homebrew/Caskroom")
		.split("\r");

	// 3. DOWNLOAD COUNTS
	// DOCS https://formulae.brew.sh/analytics/
	// source: https://formulae.brew.sh/api/analytics/cask-install/homebrew-cask/90d.json

	// TODO this is still a dummy path (implement)
	const cask90d = "/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/File Hub/cask90d.json";
	const caskDownloads = JSON.parse(readFile(cask90d)).formulae; // yes, named not named "casks" here
	const formula90d =
		"/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/File Hub/formula90d.json";
	const formulaDownloads = JSON.parse(readFile(formula90d)).formulae;

	// 4. ICONS
	const caskIcon = "🛢️";
	const formulaIcon = "🍺";

	//───────────────────────────────────────────────────────────────────────────

	/** @type{AlfredItem[]} */
	const casks = casksData.map((/** @type {Cask} */ cask) => {
		const name = cask.token;
		const installedIcon = installedBrews.includes(name) ? " ✅" : "";
		const downloads = caskDownloads[name] ? `${caskDownloads[name][0].count}↓ ` : "";
		return {
			title: name + installedIcon,
			match: alfredMatcher(name) + cask.desc,
			subtitle: `${caskIcon} ${downloads}· ${cask.desc}`,
			arg: `--cask ${name}`,
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
	const formulas = formulaData.map((/** @type {Formula} */ formula) => {
		const name = formula.name;
		const installedIcon = installedBrews.includes(name) ? " ✅" : "";
		const dependencies = formula.dependencies.length > 0 ? ` +${formula.dependencies.length}d ` : "";
		const caveats = formula.caveats || "";
		const caveatIcon = caveats ? " ℹ️ " : "";
		const downloads = caskDownloads[name] ? `${caskDownloads[name][0].count}↓ ` : "";
		return {
			title: name + installedIcon,
			match: alfredMatcher(name) + formula.desc,
			subtitle: `${formulaIcon}${dependencies}${downloads}${caveatIcon} · ${formula.desc}`,
			arg: `--formula ${name}`,
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

	console.log(`Total: ${formulas.length} formulas, ${casks.length} casks`);
	return JSON.stringify({ items: [...casks, ...formulas] });
}
