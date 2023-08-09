#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_/]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
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
	const cacheAgeThreshold = parseInt($.getenv("cache_age_threshold")) || 15;
	ensureCacheFolderExists();
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeMins = (+new Date() - cacheObj.creationDate()) / 1000 / 60;
	return cacheAgeMins > cacheAgeThreshold;
}

//──────────────────────────────────────────────────────────────────────────────

// INFO Not searching awesome neovim, neovimscraft scraps them
const neovimcraftURL = "https://nvim.sh/s";

const installedPluginsPath = $.getenv("plugin_installation_path").replace(/^~/, app.pathTo("home folder"));
const installedPlugins = app
	.doShellScript(
		`find "${installedPluginsPath}" -path "*/.git" -type d -maxdepth 3 |
		while read -r line ; do
			cd "$line"/..
			git remote -v | head -n1
		done`,
	)
	.split("\r")
	.map((/** @type {string} */ remote) => {
		return remote.slice(26, -12).replaceAll(".git (fetch)", ""); // for lazy.nvim
	});

//──────────────────────────────────────────────────────────────────────────────

const jsonArray = httpRequest(neovimcraftURL)
	.split("\n")
	.slice(2)
	.map((/** @type {string} */ line) => {
		const parts = line.split(/ {2,}/);
		const repo = parts[0];
		const name = repo.split("/")[1];

		// subtitles
		const stars = parts[1];
		const openIssues = parts[2];
		const daysAgo = Math.ceil((+new Date() - +new Date(parts[3])) / 1000 / 3600 / 24);
		let updated = daysAgo < 31 ? daysAgo.toString() + " days ago" : Math.ceil(daysAgo / 30).toString() + " months ago";
		if (updated.startsWith("1 ")) updated = updated.replace("s ago", " ago"); // remove plural "s"
		const desc = parts[4] || "";
		let subtitle = `★ ${stars} – ${updated}`;
		if (desc) subtitle += " – " + desc;

		// install icon
		const installedIcon = installedPlugins.includes(repo) ? " ✅" : "";

		return {
			title: name + installedIcon,
			match: alfredMatcher(repo),
			subtitle: subtitle,
			arg: repo,
			uid: repo,
			mods: { shift: { subtitle: `⇧: Search Issues (${openIssues} open)` } },
		};
	});

JSON.stringify({ items: jsonArray });
