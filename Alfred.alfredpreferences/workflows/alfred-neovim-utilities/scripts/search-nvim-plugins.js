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

//──────────────────────────────────────────────────────────────────────────────

// INFO Using the crawler result of `store.nvim`, since it is it includes more
// plugins that awesome-neovim, and neovimcraft and dotfyle only include plugins
// that are in the awesome-neovim
// SOURCE https://github.com/alex-popov-tech/store.nvim/blob/main/lua/store/config.lua
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
 * @property {string[]} topics
 * @property {{initial: string, lazyConfig: string}} install
 */

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// determine local plugins
	const pluginInstallPath = $.getenv("plugin_installation_path");
	let /** @type {string[]} */ installedPlugins = [];
	if (fileExists(pluginInstallPath)) {
		const shellCmd = `cd "${pluginInstallPath}" && grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config`;
		installedPlugins = app
			.doShellScript(shellCmd)
			.split("\r")
			.map((remote) => {
				const ownerAndName = remote.split("/").slice(3, 5).join("/").slice(0, -4);
				return ownerAndName;
			});
	}

	// get data & log it
	let nvimStoreData = [];
	try {
		nvimStoreData = JSON.parse(httpRequest(storeNvimList));
	} catch (_error) {
		const item = { title: "Cannot retrieve data", valid: false };
		return JSON.stringify({ items: [item] });
	}
	console.log("Last crawl:", new Date(nvimStoreData.meta.crawled_at).toLocaleString());
	console.log("Total plugins:", nvimStoreData.meta.total_count);

	// construct Alfred items
	const pluginsArr = JSON.parse(httpRequest(storeNvimList))
		.items.sort(
			(/** @type {StoreNvimRepo} */ a, /** @type {StoreNvimRepo} */ b) =>
				new Date(b.pushed_at).getTime() - new Date(a.pushed_at).getTime(),
		)
		.map((/** @type {StoreNvimRepo} */ repo) => {
			const { full_name, description, html_url, pretty_stargazers_count, pretty_pushed_at } =
				repo;
			const [author, name] = full_name.split("/");
			const installedIcon = installedPlugins.includes(full_name) ? " ✅" : "";
			const subtitle = [
				"⭐ " + pretty_stargazers_count,
				author,
				pretty_pushed_at,
				description,
			].join("  ·  ");

			return {
				title: name + installedIcon,
				match: alfredMatcher(full_name),
				subtitle: subtitle,
				arg: html_url,
				mods: {
					cmd: { arg: repo },
				},
				quicklookurl: html_url,
				uid: repo,
			};
		});

	return JSON.stringify({
		items: pluginsArr,
		cache: { seconds: 300, loosereload: true }, // faster, to update install icons
	});
}
