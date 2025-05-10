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
	if (!finder.exists(Path(cacheDir))) {
		console.log("Cache directory does not exist and is created.");
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
	const cacheAgeThresholdHours = 24; // CONFIG
	ensureCacheFolderExists();
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeHours = (Date.now() - +cacheObj.creationDate()) / 1000 / 60 / 60;
	return cacheAgeHours > cacheAgeThresholdHours;
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
function run() {
	// CACHE
	const gameListCachePath = $.getenv("alfred_workflow_cache") + "/games.json";
	console.log("🪚 gameListCachePath:", gameListCachePath);
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

	// ITEMS
	const baseUrl = "https://store.steampowered.com/app/";
	/** @type {AlfredItem[]} */
	const games = JSON.parse(response).map((/** @type {SteamGame} */ item) => {
		const url = baseUrl + item.appid;

		/** @type {AlfredItem} */
		const alfredItem = {
			title: item.name,
			arg: url,
		};
		return alfredItem;
	});

	return JSON.stringify({ items: games });
}
