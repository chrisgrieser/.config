#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const standardApp = Application.currentApplication();
standardApp.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/**
 * @typedef {Object} MacAppStoreResult
 * @property {string} trackName - Name of the app.
 * @property {string} bundleId
 * @property {string} version
 * @property {string} trackViewUrl - URL to the app's page in the Mac App Store.
 * @property {string} description
 * @property {string} sellerName - Developer or company name.
 * @property {string} sellerUrl - website of developer
 * @property {string} currentVersionReleaseDate - date string
 * @property {number} averageUserRating - Average user rating (0–5 scale).
 * @property {number} userRatingCount - Total number of user ratings.
 * @property {string[]} screenshotUrls - List of screenshot image URLs.
 * @property {string} artworkUrl100 - URL to 100x100 app icon image.
 * @property {string} artworkUrl60
 * @property {string} formattedPrice - App price as a formatted string (e.g. "$4.99").
 * @property {string} currency - Currency code (e.g. "USD").
 * @property {number} price
 * @property {number} fileSizeBytes
 * @property {number} trackId - id also used by `mas` cli
 */

/** @param {string|Date} date @return {string} relative date */
function relativeDate(date) {
	const absDate = typeof date === "string" ? new Date(date) : date;
	const deltaHours = (Date.now() - +absDate) / 1000 / 60 / 60;
	/** @type {"year"|"month"|"week"|"day"|"hour"} */
	let unit;
	let delta;
	if (deltaHours < 24) {
		unit = "hour";
		delta = deltaHours;
	} else if (deltaHours < 24 * 7) {
		unit = "day";
		delta = Math.floor(deltaHours / 24);
	} else if (deltaHours < 24 * 7 * 4) {
		unit = "week";
		delta = Math.floor(deltaHours / 24 / 7);
	} else if (deltaHours < 24 * 7 * 4 * 12) {
		unit = "month";
		delta = Math.floor(deltaHours / 24 / 7 / 4);
	} else {
		unit = "year";
		delta = Math.floor(deltaHours / 24 / 7 / 4 / 12);
	}
	const formatter = new Intl.RelativeTimeFormat("en", { style: "short", numeric: "auto" });
	return formatter.format(-delta, unit);
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

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

/**
 * @param {MacAppStoreResult} theApp
 * @return {string=} cached path
 */
function downloadImageOrGetCached(theApp) {
	const arkwork = theApp.artworkUrl60 || theApp.artworkUrl100;
	if (!arkwork) return "./icon.png"; // use default image of this workflow
	const imageCache = $.getenv("alfred_workflow_cache");
	const path = `${imageCache}/${theApp.bundleId}.png`;
	if (!fileExists(path)) standardApp.doShellScript(`curl --silent '${arkwork}' > '${path}'`);
	return path;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const useAppLogos = $.getenv("use_app_logos") === "1";
	const limit = Number.parseInt($.getenv("result_number"));

	const query = argv[0] || "";
	if (query === "") {
		return JSON.stringify({
			items: [{ title: "Mac App Store Search", subtitle: "Enter a search term…", valid: false }],
		});
	}

	// CAVEAT this assumes that the device locale is also the app store locale.
	// (This is almost always the case.)
	const regionCode = ObjC.unwrap($.NSLocale.currentLocale.objectForKey($.NSLocaleCountryCode));
	console.log("Region Code:", regionCode); // e.g., "DE", "US"

	const apiURL =
		"https://itunes.apple.com/search?entity=macSoftware" +
		`&country=${regionCode}&limit=${limit}&term=${encodeURIComponent(query)}`;
	const result = JSON.parse(httpRequest(apiURL))?.results;
	if (!result) return JSON.stringify({ items: [{ title: "Error: No results", valid: false }] });

	const installedApps = standardApp
		.doShellScript("mdfind 'kMDItemAppStoreHasReceipt == 1 && kMDItemKind == Application'")
		.split("\r")
		.map((line) => line.replace(/.*\/(.*)\.app$/, "$1"));

	ensureCacheFolderExists();
	/** @type {AlfredItem[]} */
	const apps = result.map((/** @type {MacAppStoreResult} */ app) => {
		const imagePath = useAppLogos ? downloadImageOrGetCached(app) : "./icon.png";

		const subtitle = [
			app.price > 0 ? app.formattedPrice : "",
			app.averageUserRating ? `★ ${app.averageUserRating.toFixed(1)}` : null,
			relativeDate(app.currentVersionReleaseDate),
			`${(app.fileSizeBytes / 1024 / 1024).toFixed(1)}Mb`,
			app.description,
		]
			.filter(Boolean)
			.join("  ·  ");

		const emoji = installedApps.includes(app.trackName) ? " ✅" : "";

		/** @type {AlfredItem} */
		const alfredItem = {
			title: app.trackName + emoji,
			subtitle: subtitle,
			arg: app.trackViewUrl,
			icon: { path: imagePath || "" },
			quicklookurl: app.screenshotUrls[0] || "",
			mods: {
				cmd: {
					arg: app.sellerUrl || "",
					valid: Boolean(app.sellerUrl),
					subtitle: app.sellerUrl ? "⌘: Open " + app.sellerUrl : "⛔ No website found.",
				},
				ctrl: {
					arg: app.bundleId,
					subtitle: `⌃: Copy Bundle ID "${app.bundleId}"`,
				},
			},
		};
		return alfredItem;
	});

	return JSON.stringify({ items: apps });
}
