#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (finder.exists(Path(cacheDir))) return;
	console.log("Cache directory does not exist and is created.");
	const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
	const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
	finder.make({
		new: "folder",
		at: Path(cacheDirParent),
		withProperties: { name: cacheDirBasename },
	});
}

/** @param {string} path */
function cacheIsOutdated(path) {
	const cacheAgeThresholdDays = Number.parseInt($.getenv("cache_refresh_days"));
	ensureCacheFolderExists();
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeDays = (Date.now() - +cacheObj.creationDate()) / 1000 / 60 / 60 / 24;
	return cacheAgeDays > cacheAgeThresholdDays;
}

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

/** @typedef {Object} SteamGame
 * @property {string} name
 * @property {number} appid
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = (argv[0] || "").toLowerCase();

	// PERF since Alfred cannot handle too many items.
	const minLength = 4;
	if (query.length < minLength) {
		return JSON.stringify({
			items: [
				{ title: "Query must be at least " + minLength + " characters long.", valid: false },
			],
		});
	}

	// PERF CACHE (game is 12+ Mb)
	const gameListCachePath = $.getenv("alfred_workflow_cache") + "/games.json";
	let response;
	if (cacheIsOutdated(gameListCachePath)) {
		const apiURL = "https://api.steampowered.com/ISteamApps/GetAppList/v2/";
		response = httpRequest(apiURL);
		if (!response) {
			return JSON.stringify({ items: [{ title: "Error: No results", valid: false }] });
		}
		writeToFile(gameListCachePath, response);
	} else {
		response = readFile(gameListCachePath);
	}

	// list of games installed locally
	const manifestsPath =
		app.pathTo("home folder") + "/Library/Application Support/Steam/steamapps/";
	const installedAppids = app
		.doShellScript(`find "${manifestsPath}" -type f -name "*.acf" -mindepth 1 -maxdepth 1`)
		.split("\r")
		.map((line) => {
			const [_, appid] = line.match(/appmanifest_(\d+)\.acf$/) || ["", ""];
			return Number.parseInt(appid);
		});

	// ITEMS
	const list = JSON.parse(response).applist.apps;
	const games = list
		.reduce((/** @type {AlfredItem[]} */ acc, /** @type {SteamGame} */ game) => {
			const matchesQuery = game.name.toLowerCase().includes(query);
			if (matchesQuery) {
				const emoji = installedAppids.includes(game.appid) ? " ✅" : "";
				acc.push({
					title: game.name + emoji,
					arg: game.appid,
				});
			}
			return acc;
		}, [])
		.sort( // sort by name length
			(/** @type {AlfredItem} */ a, /** @type {AlfredItem} */ b) =>
				a.title.length - b.title.length,
		);

	return JSON.stringify({ items: games });
}
