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
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	const requestStr = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
	return requestStr;
}

const mdLinkRegex = /\[(.+?)\]\((.+?)\) - (.*)/;

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

// INFO Searching awesome-neovim instead of neovimcraft or dotfyle, since the
// the latter two only scrape awesome-neovim anyway

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// determine local plugins
	const pluginInstallPath = $.getenv("plugin_installation_path");
	/** @type {string[]} */
	let installedPlugins = [];
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

	// awesome-neovim list
	const awesomeNeovimList =
		"https://raw.githubusercontent.com/rockerBOO/awesome-neovim/main/README.md";

	/** @type {AlfredItem|{}[]} */
	const pluginsArr = httpRequest(awesomeNeovimList)
		.split("\n")
		.map((/** @type {string} */ line) => {
			if (!line.startsWith("- [") || !line.includes("/")) return {};

			const [_, repo, url, desc] = line.match(mdLinkRegex) || [];
			if (!repo || !url) return {};
			const [author, name] = repo.split("/") || [];
			const installedIcon = installedPlugins.includes(repo) ? " ✅" : "";

			/** @type {AlfredItem} */
			const alfredItem = {
				title: name + installedIcon,
				match: alfredMatcher(repo),
				subtitle: author + "  ·  " + desc,
				arg: url,
				quicklookurl: url,
				uid: repo,
			};
			return alfredItem;
		});

	return JSON.stringify({
		items: pluginsArr,
		cache: {
			seconds: 300, // faster, to update install icons
			loosereload: true,
		},
	});
}
