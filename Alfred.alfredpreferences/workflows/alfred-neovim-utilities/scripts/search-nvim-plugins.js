#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_./]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

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
	const cacheAgeThresholdHours = 12; // CONFIG
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeHours = (Date.now() - cacheObj.creationDate().getTime()) / 1000 / 60 / 60;
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

//──────────────────────────────────────────────────────────────────────────────

// INFO Using the crawler result of `store.nvim`, since it is it includes more
// plugins that awesome-neovim, and neovimcraft and dotfyle only include plugins
// that are in the awesome-neovim
// SOURCE https://github.com/alex-popov-tech/store.nvim/blob/main/lua/store/config.lua
// SOURCE https://github.com/alex-popov-tech/store.nvim.crawler/issues/1#issuecomment-3146734037
const storeNvimList =
	"https://gist.githubusercontent.com/alex-popov-tech/dfb6adf1ee0506461d7dc029a28f851d/raw/ad13fe0448bb3af2afeccd7615136b7a7c5ce4d7/db_minified.json";

/** @typedef {Object} StoreNvimRepo
 * @property {string} full_name
 * @property {string} description
 * @property {string} homepage
 * @property {string} html_url
 * @property {string} pushed_at Date string
 * @property {string} pretty_pushed_at humean readable date
 * @property {string} pretty_stargazers_count
 * @property {string[]} tags
 * @property {{initial: string, lazyConfig: string}} install
 */

/** @typedef {Object} StoreNvimData
 * @property {StoreNvimRepo[]} items
 * @property {{total_count: number, crawled_at: string}} meta
 */
//───────────────────────────────────────────────────────────────────────────

/**
 * @param {(AlfredItem & {fullRepo: string})[]} alfredItems
 * @return {AlfredItem[]} updated items
 */
function addIconsForInstalledPlugins(alfredItems) {
	const pluginInstallPath = $.getenv("plugin_installation_path");
	if (!fileExists(pluginInstallPath)) return alfredItems;

	let /** @type {string[]} */ installedPlugins = [];
	const shellCmd = `cd "${pluginInstallPath}" && grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config`;
	installedPlugins = app
		.doShellScript(shellCmd)
		.split("\r")
		.map((remote) => {
			const ownerAndName = remote.split("/").slice(3, 5).join("/").slice(0, -4);
			return ownerAndName;
		});

	const updatedItems = alfredItems.map((item) => {
		if (installedPlugins.includes(item.fullRepo)) item.title += " ✅";
		return item;
	});
	return updatedItems;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	ensureCacheFolderExists();
	const cachePath = $.getenv("alfred_workflow_cache") + "/nvimPluginsAlfredItems.json";

	// use cached items (PERF not using Alfred's caching, so install icons can be updated)
	if (!cacheIsOutdated(cachePath)) {
		const alfredItems = JSON.parse(readFile(cachePath));
		const itemsWithInstallIcons = addIconsForInstalledPlugins(alfredItems);
		return JSON.stringify({ items: itemsWithInstallIcons });
	}

	// fetch data
	let /** @type {StoreNvimData} */ nvimStoreData;
	try {
		nvimStoreData = JSON.parse(httpRequest(storeNvimList));
	} catch (_error) {
		const errItem = { title: "Cannot retrieve data", valid: false };
		return JSON.stringify({ items: [errItem] });
	}
	console.log("Fetched new data from store.nvim.");
	console.log("Last crawl:", new Date(nvimStoreData.meta.crawled_at).toLocaleString());
	console.log("Total plugins:", nvimStoreData.meta.total_count);

	// construct Alfred items
	const alfredItems = nvimStoreData.items
		.sort((a, b) => new Date(b.pushed_at).getTime() - new Date(a.pushed_at).getTime())
		.map((repo) => {
			// biome-ignore format: does not need to be read so often
			const { full_name, description, html_url, pretty_stargazers_count, pretty_pushed_at, install, tags } = repo;
			const [author, name] = full_name.split("/");

			const subtitle = [
				"⭐ " + pretty_stargazers_count,
				author,
				pretty_pushed_at, // PENDING https://github.com/alex-popov-tech/store.nvim.crawler/issues/3
				description,
			].join("  ·  ");
			const lazyNvimInstall = install?.lazyConfig;

			/** @type {(AlfredItem & {fullRepo: string})} */
			const item = {
				title: name,
				fullRepo: full_name, // just for adding of the install icon adding
				match: alfredMatcher([name, author, ...tags].join(" ")),
				subtitle: subtitle,
				arg: html_url,
				mods: {
					cmd: { arg: full_name }, // open help page
					ctrl: {
						arg: lazyNvimInstall,
						valid: Boolean(lazyNvimInstall),
						subtitle: lazyNvimInstall
							? "⌃: Install with lazy.nvim"
							: "⌃: ⛔ No install snippet available, please install manually",
					},
				},
				quicklookurl: html_url,
			};
			return item;
		});
	writeToFile(cachePath, JSON.stringify(alfredItems));

	const itemsWithInstallIcons = addIconsForInstalledPlugins(alfredItems);
	return JSON.stringify({ items: itemsWithInstallIcons });
}
