#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const alfredMatcher = (/** @type {string} */ str) => str.replaceAll("-", " ") + " " + str + " ";

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (!finder.exists(Path(cacheDir))) {
		console.log("Cache Dir does not exist and is created.");
		const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
		finder.make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: cacheDirBasename },
		});
	}
}

/** @param {string} path */
function cacheIsOutdated(path) {
	ensureCacheFolderExists();
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeDays = (+new Date() - cacheObj.creationDate()) / 1000 / 60 / 60 / 24;
	const cacheAgeThresholdDays = 7;
	return cacheAgeDays > cacheAgeThresholdDays;
}

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

//──────────────────────────────────────────────────────────────────────────────
// MAIN DATA
/** @typedef {object} Formula
 * @property {string} name
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
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const timelogStart = +new Date();

	// 1. MAIN DATA (already cached by homebrew)
	// DOCS https://formulae.brew.sh/docs/api/ & https://docs.brew.sh/Querying-Brew
	// these files contain the API response of casks and formulas as payload; they
	// are updated on each `brew update`. Since they are effectively caches,
	// there is no need create caches of our own.
	const caskJson = app.pathTo("home folder") + "/Library/Caches/Homebrew/api/cask.jws.json";
	const formulaJson = app.pathTo("home folder") + "/Library/Caches/Homebrew/api/formula.jws.json";
	if (!fileExists(formulaJson) || !fileExists(caskJson)) app.doShellScript("brew update");

	// SIC data must be parsed twice, since that is how the cache is saved by homebrew
	const casksData = JSON.parse(JSON.parse(readFile(caskJson)).payload);
	const formulaData = JSON.parse(JSON.parse(readFile(formulaJson)).payload);

	// 2. LOCAL INSTALLATION DATA (determined live every run)
	// PERF `ls` quicker than `brew list` or the API
	const installedBrews = app
		.doShellScript('cd "$(brew --prefix)" ; ls -1 ./Cellar ; ls -1 ./Caskroom')
		.split("\r");

	// 3. DOWNLOAD COUNTS (cached by me)
	// DOCS https://formulae.brew.sh/analytics/
	const cask90d = $.getenv("alfred_workflow_cache") + "/caskDownloads90d.json";
	const formula90d = $.getenv("alfred_workflow_cache") + "/formulaDownloads90d.json";
	if (cacheIsOutdated(cask90d)) {
		console.log("Updating download count cache…");
		const caskDownloads = httpRequest(
			"https://formulae.brew.sh/api/analytics/cask-install/homebrew-cask/90d.json",
		);
		const formulaDownloads = httpRequest(
			"https://formulae.brew.sh/api/analytics/install-on-request/homebrew-core/90d.json",
		);
		writeToFile(cask90d, caskDownloads);
		writeToFile(formula90d, formulaDownloads);
	}
	const caskDownloads = JSON.parse(readFile(cask90d)).formulae;
	const formulaDownloads = JSON.parse(readFile(formula90d)).formulae; // SIC not .casks

	// 4. ICONS
	const caskIcon = "🛢️";
	const formulaIcon = "🍺";
	const caveatIcon = "ℹ️";
	const installedIcon = "✅";
	const deprecatedIcon = "⚠️";

	//───────────────────────────────────────────────────────────────────────────

	/** @type{AlfredItem[]} */
	const casks = casksData.map((/** @type {Cask} */ cask) => {
		const name = cask.token;

		let icons = "";
		if (installedBrews.includes(name)) icons += " " + installedIcon;
		if (cask.deprecated) icons += `   ${deprecatedIcon} [deprecated]`;

		const downloads = caskDownloads[name] ? `${caskDownloads[name][0].count}↓ ` : "";
		const desc = cask.desc ? "·  " + cask.desc : ""; // default to empty string instead of "null"
		return {
			title: name + icons,
			match: alfredMatcher(name) + desc,
			subtitle: `${caskIcon} ${downloads} ${desc}`,
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
			uid: name, // remember selections
		};
	});

	/** @type{AlfredItem[]} */
	const formulas = formulaData.map((/** @type {Formula} */ formula) => {
		const name = formula.name;
		let icons = "";
		if (installedBrews.includes(name)) icons += " " + installedIcon;
		if (formula.deprecated) icons += `   ${deprecatedIcon} deprecated`;

		const caveatText = formula.caveats || "";
		const caveats = caveatText ? caveatIcon + " " : "";
		const downloads = formulaDownloads[name] ? `${formulaDownloads[name][0].count}↓ ` : "";
		const desc = formula.desc ? "·  " + formula.desc : ""; // no "null" as desc

		return {
			title: name + icons,
			match: alfredMatcher(name) + desc,
			subtitle: `${formulaIcon} ${caveats}${downloads} ${desc}`,
			arg: `--formula ${name}`,
			text: {
				largetype: caveatText,
				copy: caveatText,
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
			uid: name, // remember selections
		};
	});

	const duration = (+new Date() - timelogStart) / 1000;
	console.log(`Total: ${formulas.length} formulas, ${casks.length} casks (${duration}s)`);

	// PERF merging via spread operator performs slightly faster than
	// concatenation with the number array elements cp.
	// https://javascript.plainenglish.io/efficiently-merging-arrays-in-javascript-32993788a8b2
	return JSON.stringify({ items: [...casks, ...formulas] });
}
