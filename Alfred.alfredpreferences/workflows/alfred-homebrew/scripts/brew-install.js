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

/** @typedef {object} Formula
 * @property {string} name
 * @property {string} caveats
 * @property {string} desc
 * @property {string} homepage
 * @property {boolean} deprecated
 * @property {object[]} installed WARN do not use this field, since the data there is empty, despite the homebrew docs suggesting otherwise
 * @property {string[]} dependencies
 */

/** @typedef {object} Cask
 * @property {string} token
 * @property {string} desc
 * @property {string} homepage
 * @property {boolean} deprecated
 * @property {object} installed WARN do not use this field, since the data there is empty, despite the homebrew docs suggesting otherwise
 * @property {Record<string, string|string[]>} depends_on_args
 */

/**
 * @param {string} title
 * @param {string=} subtitle
 * @param {string=} arg
 */
function alfredErrorItem(title, subtitle, arg) {
	const icon = arg ? "⛔" : "⚠️";
	return JSON.stringify({
		items: [
			{
				title: icon + " " + title,
				subtitle: subtitle,
				valid: Boolean(arg),
				arg: arg || "",
			},
		],
	});
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const caskIcon = "🛢️";
	const formulaIcon = "🍺";
	const installedIcon = "✅";
	const deprecatedIcon = "⚠️";

	// 0. Version check since Homebrew API changed with 6.0
	const brewVersionStr =
		app.doShellScript("brew --version").match(/Homebrew (\d+\.\d)/)?.[1] || "0";
	console.log("Homebrew version: " + brewVersionStr);
	const brewVersion = Number(brewVersionStr);
	if (brewVersion < 6.0) {
		return alfredErrorItem(
			"This workflow now requires Homebrew 6.0 or newer.",
			"You can update Homebrew by running `brew update` in your terminal.",
		);
	}

	// 1. MAIN DATA (already cached by homebrew)
	// DOCS https://formulae.brew.sh/docs/api/ & https://docs.brew.sh/Querying-Brew
	// This file contains the API response of casks and formulas as payload; they
	// are updated on each `brew update`. Since they are effectively caches,
	// there is no need create caches of our own.
	const apiCacheFolder = app.pathTo("home folder") + "/Library/Caches/Homebrew/api/internal";
	const brewCache = apiCacheFolder + "/packages.arm64_tahoe.jws.json";

	if (!fileExists(brewCache)) {
		app.doShellScript("brew update"); // re-creates the cache

		// in case homebrew uses a different cache location, e.g. for other architectures
		const apiCache = app.doShellScript('ls -1 "$HOME/Library/Caches/Homebrew/api/internal"');
		console.log("Files in API cache folder:", apiCache);
		if (!fileExists(brewCache)) {
			return alfredErrorItem(
				"Unable to find Homebrew cache file.",
				"↩: Report the issue on GitHub: https://github.com/chrisgrieser/alfred-homebrew/issues/21",
				"https://github.com/chrisgrieser/alfred-homebrew/issues/21",
			);
		}
	}

	// SIC data must be parsed twice, since that is how the cache is saved by homebrew
	const brewData = JSON.parse(JSON.parse(readFile(brewCache)).payload);

	// 2. LOCAL INSTALLATION DATA (determined live every run)
	// PERF `ls` quicker than `brew list` (and the json files miss actual installation info)
	const installedFormulas = app.doShellScript('ls -1 "$(brew --prefix)/Cellar"').split("\r");
	const installedCasks = app.doShellScript('ls -1 "$(brew --prefix)/Caskroom"').split("\r");

	// 3. DOWNLOAD COUNTS (cached by this workflow)
	// DOCS https://formulae.brew.sh/analytics/
	// separate from Alfred's caching, since installed packages should be checked more frequently
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
	/** @type{(AlfredItem&{downloads:number})[]} */
	const casks = Object.entries(brewData.casks).map(([name, cask]) => {
		let icons = "";
		if (installedCasks.includes(name)) icons += " " + installedIcon;
		if (cask.deprecated) icons += `   [${deprecatedIcon} deprecated]`;

		const downloads = caskDownloads[name] ? `${caskDownloads[name][0].count}↓` : "";
		const desc = cask.desc || "";

		let deps = "";
		const depsInfo = cask.depends_on_args?.[":macos"];
		if (depsInfo !== ":any" && typeof depsInfo === "string") {
			const info = depsInfo.replace(
				/([_:])([a-z])/g,
				(_, sep, char) => (sep === "_" ? " " : "") + char.toUpperCase(),
			);
			deps = ` [requires ${info}]`;
		}

		return {
			title: name + icons,
			match: alfredMatcher(name) + desc,
			subtitle: [caskIcon, downloads, deps, " ", desc].join(" "),
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

	/** @type{(AlfredItem&{downloads:number})[]} */
	const formulas = Object.entries(brewData.formulae).map(([name, formula]) => {
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
	// a. move shorter package names top, since short names like `sd` are
	// otherwise ranked further down, making them often hard to find
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
