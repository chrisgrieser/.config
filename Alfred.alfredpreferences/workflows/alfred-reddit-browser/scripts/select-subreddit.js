#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

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

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (!finder.exists(Path(cacheDir))) {
		const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
		finder.make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: cacheDirBasename },
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────

/**
 * @param {string} subredditName
 * @return {any?} subredditInfo
 */
function getSubredditInfo(subredditName) {
	// INFO user agent is required to avoid network security error by reddit
	const userAgent =
		"Alfred " + $.getenv("alfred_workflow_name") + "/" + $.getenv("alfred_workflow_version");

	const apiUrl = `https://www.reddit.com/r/${subredditName}/about.json`;
	const curlCommand = `curl --silent --location --user-agent "${userAgent}" "${apiUrl}"`;
	const response = app.doShellScript(curlCommand);
	let subredditInfo;
	try {
		subredditInfo = JSON.parse(response);
	} catch (_error) {
		console.log("reddit did not respond with JSON.");
		return;
	}
	if (subredditInfo.error) {
		console.log(`${subredditInfo.error}: ${subredditInfo.message}`);
		return;
	}

	return subredditInfo;
}

/** gets subreddit icon
 * @param {string} iconPath
 * @param {string} subredditName
 */
function cacheSubredditIcon(iconPath, subredditName) {
	const subredditInfo = getSubredditInfo(subredditName);
	if (!subredditInfo) return;

	// for some subreddits saved as icon_img, for others as community_icon
	let onlineIcon = subredditInfo.data.icon_img || subredditInfo.data.community_icon;
	if (!onlineIcon) return;
	onlineIcon = onlineIcon.replace(/\?.*$/, ""); // clean url for curl

	// cache icon
	app.doShellScript(
		`curl --silent --location "${onlineIcon}" --create-dirs --output "${iconPath}"`,
	);
}

/**
 * @param {string} subredditName
 * @return {false|number} subscriber count
 */
function cacheAndReturnSubCount(subredditName) {
	const subredditInfo = getSubredditInfo(subredditName);
	if (!subredditInfo) return false;

	ensureCacheFolderExists();
	const cachePath = $.getenv("alfred_workflow_cache") + "/subscriberCount.json";
	const subscriberCount = subredditInfo.data.subscribers
		.toString()
		.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
	const subscriberData = JSON.parse(readFile(cachePath) || "{}");
	subscriberData[subredditName] = subscriberCount;
	writeToFile(cachePath, JSON.stringify(subscriberData));
	return subscriberCount;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const iconFolder = $.getenv("custom_subreddit_icons") || $.getenv("alfred_workflow_data");
	const subredditConfig = $.getenv("subreddits")
		.trim()
		.replace(/^\/?r\//gm, ""); // can be `r/` or `/r/` https://www.alfredforum.com/topic/20813-reddit-browser/page/2/#comment-114645

	const subreddits = subredditConfig.split("\n").map((subredditName) => {
		let subtitle = "";

		// cache subreddit image
		let iconPath = `${iconFolder}/${subredditName}.png`;
		if (!fileExists(iconPath)) {
			cacheSubredditIcon(iconPath, subredditName);
			if (!fileExists(iconPath)) iconPath = "icon.png"; // fallback to this workflow's icon
		}

		// subscriber count
		const cachePath = $.getenv("alfred_workflow_cache") + "/subscriberCount.json";
		const subscriberData = JSON.parse(readFile(cachePath) || "{}");
		const subscriberCount =
			subscriberData[subredditName] || cacheAndReturnSubCount(subredditName);
		subtitle += subscriberCount ? `👥 ${subscriberCount}` : "⚠️ subscriber count error ";

		/** @type {AlfredItem} */
		const alfredItem = {
			title: `r/${subredditName}`,
			subtitle: subtitle,
			arg: subredditName,
			icon: { path: iconPath },
			mods: {
				cmd: { arg: `https://www.reddit.com/r/${subredditName}/` },
			},
		};
		return alfredItem;
	});

	// add hackernews as pseudo-subreddit
	const addHackernews = $.getenv("add_hackernews") === "1";
	if (addHackernews) {
		subreddits.push({
			title: "Hackernews",
			arg: "hackernews",
			icon: { path: "hackernews.png" },
			mods: {
				cmd: { arg: "https://news.ycombinator.com/" },
			},
		});
	}

	return JSON.stringify({ items: subreddits });
}
