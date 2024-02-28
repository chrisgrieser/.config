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

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(
		requestData,
		$.NSUTF8StringEncoding,
	).js;
	return requestString;
}

//──────────────────────────────────────────────────────────────────────────────

// INFO Searching awesome-neovim instead of neovimcraft or dotfyle, since the
// the latter two only scrape awesome-neovim anyway

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// determine local plugins
	const pluginInstallPath = $.getenv("plugin_installation_path");
	const installedPlugins = app
		.doShellScript(
			`cd "${pluginInstallPath}" && grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config`,
		)
		.split("\r")
		.map((remote) => {
			const ownerAndName = remote.split("/").slice(3, 5).join("/").slice(0, -4);
			return ownerAndName;
		});

	// awesome-neovim list
	const awesomeNeovimList =
		"https://raw.githubusercontent.com/rockerBOO/awesome-neovim/main/README.md";

	/** @type {AlfredItem[]} */
	const pluginsArr = httpRequest(awesomeNeovimList)
		.split("\n")
		.map((/** @type {string} */ line) => {
			if (!line.startsWith("- [") || !line.includes("/")) return {};

			const mdLinkRegex = /\[(.+?)\]\((.+?)\) - (.*)/;
			const [_, repo, url, desc] = line.match(mdLinkRegex);
			const [author, name] = repo.split("/");
			const installedIcon = installedPlugins.includes(repo) ? " ✅" : "";

			return {
				title: name + installedIcon,
				match: alfredMatcher(repo),
				subtitle: author + "  ·  " + desc,
				arg: url,
				quicklookurl: url,
				uid: repo,
				mods: {
					shift: {
						subtitle: "⇧: Search Issues",
						arg: "",
						variables: { repoID: repo },
					},
				},
			};
		});

	return JSON.stringify({
		items: pluginsArr,
		cache: {
			seconds: 300, // faster, to update install icons
			loosereload: true,
		},
	});
}
