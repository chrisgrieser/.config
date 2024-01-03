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
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (!finder.exists(Path(cacheDir))) {
		console.log("Cache Dir does not exist and is created.");
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
	const cacheAgeThresholdHours = 24; // 24h = cache is old
	ensureCacheFolderExists();
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeHours = (+new Date() - cacheObj.creationDate()) / 1000 / 60 / 60;
	return cacheAgeHours > cacheAgeThresholdHours;
}

/**
 * @param {string} firstPath
 * @param {string} secondPath
 * @returns {boolean} firstPathOlderThanSecond
 */
function olderThan(firstPath, secondPath) {
	const firstMdate = +Application("System Events").aliases[firstPath].modificationDate();
	const secondMdate = +Application("System Events").aliases[secondPath].modificationDate();
	const firstPathOlderThanSecond = firstMdate - secondMdate < 0;
	return firstPathOlderThanSecond;
}

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

//──────────────────────────────────────────────────────────────────────────────

// INFO Searching awesome-neovim instead of neovimcraft or dotfyle, since the
// the latter two only scrape awesome-neovim anyway

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// UPDATE CACHE IF OUTDATED OR IF PLUGINS WERE INSTALLED/UNINSTALLED
	const pluginInstallPath = $.getenv("plugin_installation_path");
	// const cachePath = $.getenv("alfred_workflow_cache") + "/neovimcraftPlugins.json";
	// if (!cacheIsOutdated(cachePath) && olderThan(pluginInstallPath, cachePath))
	// 	return readFile(cachePath);

	//───────────────────────────────────────────────────────────────────────────
	// REQUEST NEOVIMCRAFT

	const awesomeNeovimList = "https://raw.githubusercontent.com/rockerBOO/awesome-neovim/main/README.md";
	const installedPlugins = app
		.doShellScript(
			`cd "${pluginInstallPath}" && grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config`,
		)
		.split("\r")
		.map((remote) => {
			const ownerAndName = remote.split("/").slice(3, 5).join("/").slice(0, -4);
			return ownerAndName;
		});

	const pluginsArr = httpRequest(awesomeNeovimList)
		.split("\n")
		.map((/** @type {string} */ line) => {
			if (!line.startsWith("- ")) return {};

			const mdLinkRegex = /\[([^\]]+)]\(([^)]+)\)/;
			const [_, repo, url, desc] = mdLinkRegex.match(line);
			const [author, name] = repo.split("/");

			// install icon
			const installedIcon = installedPlugins.includes(repo) ? " ✅" : "";

			return {
				title: name + installedIcon,
				match: alfredMatcher(repo),
				subtitle: subtitle,
				arg: url,
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

	const alfredResponse = JSON.stringify({ items: pluginsArr });
	// writeToFile(cachePath, alfredResponse);
	return alfredResponse;
}
