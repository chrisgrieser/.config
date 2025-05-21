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

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const includeMacAppStoreSetting = $.getenv("list_mac_app_store") === "1";
	const useZap = $.getenv("use_zap") === "1";

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

	const casks = casksData.reduce((/** @type{AlfredItem[]} */ acc, /** @type {Cask} */ cask) => {
		const zap = useZap ? "--zap" : "";
		const name = cask.token;
		if (cask.installed) {
			acc.push({
				title: name,
				match: alfredMatcher(name),
				subtitle: "cask",
				arg: `--cask ${zap} ${name}`,
				mods: {
					shift: { arg: `--cask ${name}` },
				},
			});
		}
		return acc;
	}, []);

	// const formulas = formulaData.reduce(
	// 	(/** @type{AlfredItem[]} */ acc, /** @type {Formula} */ formula) => {
	// 		const name = formula.name;
	// 		if (formula.installed) {
	// 			acc.push({
	// 				title: name,
	// 				match: alfredMatcher(name),
	// 				subtitle: "formula",
	// 				arg: `--formula ${name}`,
	// 				mods: {
	// 					shift: { arg: `--formula ${name}` },
	// 				},
	// 			});
	// 		}
	// 		return acc;
	// 	},
	// 	[],
	// );
	/** @type{AlfredItem[]} */
	const formulas = [];
	const allApps = [...formulas, ...casks];

	if (includeMacAppStoreSetting) {
		const appStoreApps = app
			.doShellScript("mdfind kMDItemAppStoreHasReceipt=1") // `mdfind` avoids dependency on `mas`
			.split("\r")
			.map((appPath) => {
				const appName = appPath.split("/")[2];
				const nameNoExt = appName.slice(0, -4);

				return {
					title: nameNoExt,
					match: alfredMatcher(nameNoExt),
					subtitle: "Mac App Store",
					arg: appPath,
					mods: {
						ctrl: {
							valid: false,
							subtitle: "⛔ reinstall is only supported for homebrew packages",
						},
						shift: {
							valid: false,
							subtitle: "⛔ info is only supported for homebrew packages",
						},
					},
				};
			});

		allApps.push(...appStoreApps);
	}

	return JSON.stringify({
		items: allApps,
		// cache: {
		// 	seconds: 120, // quick since leftover apps after uninstallation would be confusing
		// 	loosereload: true,
		// },
	});
}
