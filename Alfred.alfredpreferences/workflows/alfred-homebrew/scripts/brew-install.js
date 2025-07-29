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
	const cacheAgeDays = (Date.now() - cacheObj.creationDate().getTime()) / 1000 / 60 / 60 / 24;
	const cacheAgeThresholdDays = 7;
	return cacheAgeDays > cacheAgeThresholdDays;
}

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

// WARN do not use the `installed` field, since the data there is empty, despite
// the homebrew docs suggested otherwise.
/** @typedef {object} Formula
 * @property {string} name
 * @property {string} caveats
 * @property {string} desc
 * @property {string} homepage
 * @property {boolean} deprecated
 * @property {object[]} installed
 * @property {string[]} dependencies
 */

// WARN do not use the `installed` field, since the data there is empty, despite
// the homebrew docs suggested otherwise.
/** @typedef {object} Cask
 * @property {string} token
 * @property {string} desc
 * @property {string} homepage
 * @property {boolean} deprecated
 * @property {object} installed
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const caskIcon = "🛢️";
	const formulaIcon = "🍺";
	const installedIcon = "✅";
	const deprecatedIcon = "⚠️";

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
	// PERF `ls` quicker than `brew list`
	// (and the json files miss actual installation info)
	const installedFormulas = app.doShellScript('ls -1 "$(brew --prefix)/Cellar"').split("\r");
	const installedCasks = app.doShellScript('ls -1 "$(brew --prefix)/Caskroom"').split("\r");

	// 3. DOWNLOAD COUNTS (cached by this workflow)
	// DOCS https://formulae.brew.sh/analytics/
	// INFO separate from Alfred's caching mechanism, since the installed
	// packages should be determined more frequently
	const cask90d = $.getenv("alfred_workflow_cache") + "/caskDownloads90d.json";
	const formula90d = $.getenv("alfred_workflow_cache") + "/formulaDownloads90d.json";
	let caskDlRaw;
	let formulaDlRaw;
	if (cacheIsOutdated(cask90d)) {
		console.log("Updating download count cache.");
		caskDlRaw = httpRequest(
			"https://formulae.brew.sh/api/analytics/cask-install/homebrew-cask/90d.json",
		);
		formulaDlRaw = httpRequest(
			"https://formulae.brew.sh/api/analytics/install-on-request/homebrew-core/90d.json",
		);
		writeToFile(cask90d, caskDlRaw);
		writeToFile(formula90d, formulaDlRaw);
	}
	const caskDownloads = JSON.parse(caskDlRaw || readFile(cask90d)).formulae;
	const formulaDownloads = JSON.parse(formulaDlRaw || readFile(formula90d)).formulae; // SIC not `.casks`

	// 4. CREATE ALFRED ITEMS (will be cached for an hour by Alfred)
	/** @type{AlfredItem&{downloads:number}[]} */
	const casks = casksData.map((/** @type {Cask} */ cask) => {
		const name = cask.token;
		let icons = "";
		if (installedCasks.includes(name)) icons += " " + installedIcon;
		if (cask.deprecated) icons += `   [${deprecatedIcon} deprecated]`;

		const downloads = caskDownloads[name] ? `${caskDownloads[name][0].count}↓` : "";
		const desc = cask.desc || "";

		return {
			title: name + icons,
			match: alfredMatcher(name) + desc,
			subtitle: [caskIcon, downloads, " ", desc].join(" "),
			arg: `--cask ${name}`,
			variables: { brewfileLine: `cask "${name}"` },
			quicklookurl: cask.homepage,
			downloads: Number.parseInt(downloads.replace(/,/g, "")), // only for sorting
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

	/** @type{AlfredItem&{downloads:number}[]} */
	const formulas = formulaData.map((/** @type {Formula} */ formula) => {
		const name = formula.name;
		let icons = "";
		if (installedFormulas.includes(name)) icons += " " + installedIcon;
		if (formula.deprecated) icons += `   [${deprecatedIcon} deprecated]`;

		const downloads = formulaDownloads[name] ? `${formulaDownloads[name][0].count}↓` : "";
		const desc = formula.desc || "";

		return {
			title: name + icons,
			match: alfredMatcher(name) + desc,
			subtitle: [formulaIcon, downloads, " ", desc].join(" "),
			arg: `--formula ${name}`,
			variables: { brewfileLine: `brew "${name}"` },
			quicklookurl: formula.homepage,
			downloads: Number.parseInt(downloads.replaceAll(",", "")), // only for sorting
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

	// 5. MERGE & SORT BOTH LISTS
	// a. move shorter package names top, since short names like `sd` are otherwise ranked
	//    further down, making them often hard to find
	// b. sort by download count as secondary criteria
	const allPackages = [...casks, ...formulas].sort((/** @type{any} */ a, /** @type{any} */ b) => {
		const titleLengthDiff = a.title.length - b.title.length;
		if (titleLengthDiff !== 0) return titleLengthDiff;
		const downloadCountDiff = (b.downloads || 0) - (a.downloads || 0);
		return downloadCountDiff;
	});

	return JSON.stringify({
		items: allPackages,
		cache: { seconds: 3600, loosereload: true }, // update regularly for correct identification of installed packages
	});
}
