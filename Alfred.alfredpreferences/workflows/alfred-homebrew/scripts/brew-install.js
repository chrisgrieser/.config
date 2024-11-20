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
	const cacheAgeDays = (Date.now() - +cacheObj.creationDate()) / 1000 / 60 / 60 / 24;
	const cacheAgeThresholdDays = 7;
	return cacheAgeDays > cacheAgeThresholdDays;
}

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	const requestStr = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
	return requestStr;
}

//──────────────────────────────────────────────────────────────────────────────
// MAIN DATA
/** @typedef {object} Formula
 * @property {string} name
 * @property {string} caveats
 * @property {string} desc
 * @property {string} homepage
 * @property {boolean} deprecated
 */

/** @typedef {object} Cask
 * @property {string} token
 * @property {string} desc
 * @property {string} homepage
 * @property {boolean} deprecated
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
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
	const installedPackages = app
		.doShellScript('cd "$(brew --prefix)" ; ls -1 ./Cellar ; ls -1 ./Caskroom')
		.split("\r");

	// 3. DOWNLOAD COUNTS (cached by this workflow)
	// DOCS https://formulae.brew.sh/analytics/
	// INFO separate from Alfred's caching mechanism, since the installed
	// packages should be determined more frequently
	const cask90d = $.getenv("alfred_workflow_cache") + "/caskDownloads90d.json";
	const formula90d = $.getenv("alfred_workflow_cache") + "/formulaDownloads90d.json";
	if (cacheIsOutdated(cask90d)) {
		// biome-ignore lint/suspicious/noConsole: intentional
		console.log("Updating download count cache.");
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
	const formulaDownloads = JSON.parse(readFile(formula90d)).formulae; // SIC not `.casks`

	// 4. ICONS
	const caskIcon = "🛢️ ";
	const formulaIcon = "🍺 ";
	const caveatIcon = "ℹ️ ";
	const installedIcon = "✅ ";
	const deprecatedIcon = "⚠️ ";

	// biome-ignore lint/suspicious/noConsole: intentional
	console.log("Caches ready.");

	// 5. CREATE ALFRED ITEMS
	/** @type{AlfredItem&{downloads:number}[]} */
	const casks = casksData.map((/** @type {Cask} */ cask) => {
		const name = cask.token;

		let icons = "";
		if (installedPackages.includes(name)) icons += " " + installedIcon;
		if (cask.deprecated) icons += `   ${deprecatedIcon}[deprecated]`;

		const downloads = caskDownloads[name] ? `${caskDownloads[name][0].count}↓` : "";
		const desc = cask.desc || "";
		const sep = desc && downloads ? "  ·  " : "";

		return {
			title: name + icons,
			match: alfredMatcher(name) + desc,
			subtitle: [caskIcon, downloads, sep, desc].join(""),
			arg: `--cask ${name}`,
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
		if (installedPackages.includes(name)) icons += " " + installedIcon;
		if (formula.deprecated) icons += `   ${deprecatedIcon}deprecated`;

		const caveatText = formula.caveats || "";
		const caveats = caveatText ? caveatIcon + " " : "";
		const downloads = formulaDownloads[name] ? `${formulaDownloads[name][0].count}↓` : "";
		const desc = formula.desc || "";
		const sep = desc && downloads ? "  ·  " : "";

		return {
			title: name + icons,
			match: alfredMatcher(name) + desc,
			subtitle: [formulaIcon, caveats, downloads, sep, desc].join(""),
			arg: `--formula ${name}`,
			quicklookurl: formula.homepage,
			downloads: Number.parseInt(downloads.replace(/,/g, "")), // only for sorting
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

	// 6. MERGE & SORT BOTH LISTS
	// & move shorter package names top (short names like `sd` are ranked further down otherwise)
	// & sort by download count as secondary criteria
	const allPackages = [...casks, ...formulas].sort((/** @type{any} */ a, /** @type{any} */ b) => {
		const titleLengthDiff = a.title.length - b.title.length;
		if (titleLengthDiff !== 0) return titleLengthDiff;
		const downloadCountDiff = (b.downloads || 0) - (a.downloads || 0);
		return downloadCountDiff;
	});

	return JSON.stringify({
		items: allPackages,
		cache: {
			seconds: 3600, // update regularly for correct identification of installed packages
			loosereload: true,
		},
	});
}
