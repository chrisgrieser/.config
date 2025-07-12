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

/** @param {string|Date} date @return {string} relative date */
function relativeDate(date) {
	const absDate = typeof date === "string" ? new Date(date) : date;
	const deltaMins = (Date.now() - absDate.getTime()) / 1000 / 60;
	/** @type {"year"|"month"|"week"|"day"|"hour"|"minute"} */
	let unit;
	let delta;
	if (deltaMins < 60) {
		unit = "minute";
		delta = Math.floor(deltaMins);
	} else if (deltaMins < 60 * 24) {
		unit = "hour";
		delta = Math.floor(deltaMins / 60);
	} else if (deltaMins < 60 * 24 * 7) {
		unit = "day";
		delta = Math.floor(deltaMins / 60 / 24);
	} else if (deltaMins < 60 * 24 * 7 * 4) {
		unit = "week";
		delta = Math.floor(deltaMins / 60 / 24 / 7);
	} else if (deltaMins < 60 * 24 * 7 * 4 * 12) {
		unit = "month";
		delta = Math.floor(deltaMins / 60 / 24 / 7 / 4);
	} else {
		unit = "year";
		delta = Math.floor(deltaMins / 60 / 24 / 7 / 4 / 12);
	}
	const formatter = new Intl.RelativeTimeFormat("en", { style: "narrow", numeric: "auto" });
	return formatter.format(-delta, unit);
}

//──────────────────────────────────────────────────────────────────────────────

// INFO Using the crawler result of `store.nvim`, since it is it includes more
// plugins that awesome-neovim, and neovimcraft and dotfyle only include plugins
// that are in the awesome-neovim
const storeNvimList =
	"https://gist.githubusercontent.com/alex-popov-tech/93dcd3ce38cbc7a0b3245b9b59b56c9b/raw/a4859fe73ddda67e4fb86a5cd7bc30e9889cb787/store.nvim-repos.json";

/** @typedef {Object} StoreNvimRepo
 * @property {string} full_name
 * @property {string} description
 * @property {string} homepage
 * @property {string} html_url
 * @property {number} stargazers_count
 * @property {number} watchers_count
 * @property {number} fork_count
 * @property {string} updated_at - ISO‑8601 timestamp
 * @property {string[]} topics
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

	const pluginsArr = JSON.parse(httpRequest(storeNvimList)).repositories.map(
		(/** @type {StoreNvimRepo} */ repo) => {
			const { full_name, description, html_url, stargazers_count, updated_at } = repo;
			const [author, name] = full_name.split("/");
			const installedIcon = installedPlugins.includes(full_name) ? " ✅" : "";
			const updated = relativeDate(updated_at);
			const subtitle = ["⭐ " + stargazers_count, author, updated, description].join("  ·  ");

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
		},
	);

	console.log("plugin count:", pluginsArr.length);
	return JSON.stringify({
		items: pluginsArr,
		cache: { seconds: 300, loosereload: true }, // faster, to update install icons
	});
}
