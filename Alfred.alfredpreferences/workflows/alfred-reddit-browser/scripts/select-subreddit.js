#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const iconFolder = $.getenv("custom_subreddit_icons") || $.getenv("alfred_workflow_data");

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

//──────────────────────────────────────────────────────────────────────────────

/** gets subreddit icon
 * @param {string} iconPath
 * @param {string} subredditName
 */
function cacheAndReturnSubIcon(iconPath, subredditName) {
	// HACK reddit API does not like curl (lol)
	const redditApiCall = `curl -sL -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/${subredditName}/about.json"`;
	const subredditInfo = JSON.parse(app.doShellScript(redditApiCall));
	if (subredditInfo.error) {
		console.log(`${subredditInfo.error}: ${subredditInfo.message}`);
		return false;
	}

	// for some subreddits saved as icon_img, for others as community_icon
	let onlineIcon = subredditInfo.data.icon_img || subredditInfo.data.community_icon;
	if (!onlineIcon) return true; // has no icon
	onlineIcon = onlineIcon.replace(/\?.*$/, ""); // clean url for curl

	// cache icon
	app.doShellScript(`curl -sL "${onlineIcon}" --create-dirs --output "${iconPath}"`);
	return true;
}

/** @param {string} subredditName */
function cacheAndReturnSubCount(subredditName) {
	const redditApiCall = `curl -sL -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/${subredditName}/about.json"`;
	const subredditInfo = JSON.parse(app.doShellScript(redditApiCall));
	if (subredditInfo.error) {
		console.log(`${subredditInfo.error}: ${subredditInfo.message}`);
		return undefined;
	}

	ensureCacheFolderExists();
	const subscriberCount = subredditInfo.data.subscribers
		.toString()
		.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
	const subscriberData = JSON.parse(
		readFile($.getenv("alfred_workflow_cache") + "/subscriberCount.json") || "{}",
	);
	subscriberData[subredditName] = subscriberCount;
	writeToFile(
		`${$.getenv("alfred_workflow_cache")}/subscriberCount.json`,
		JSON.stringify(subscriberData),
	);
	return subscriberCount; // = no error
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const subredditConfig = $.getenv("subreddits").trim().replace(/^r\//gm, "");

	//───────────────────────────────────────────────────────────────────────────

	const subreddits = subredditConfig.split("\n").map((subredditName) => {
		let subtitle = "";

		// cache subreddit image
		let iconPath = `${iconFolder}/${subredditName}.png`;
		if (!fileExists(iconPath)) {
			const success = cacheAndReturnSubIcon(iconPath, subredditName);
			if (!fileExists(iconPath)) iconPath = "icon.png"; // if icon cannot be cached, use default
			if (!success) subtitle += "⚠️ subreddit icon error ";
		}

		// subscriber count
		const subscriberData = JSON.parse(
			readFile($.getenv("alfred_workflow_cache") + "/subscriberCount.json") || "{}",
		);
		const subscriberCount = subscriberData[subredditName] || cacheAndReturnSubCount(subredditName);
		if (!subscriberCount) subtitle += "⚠️ subscriber count error ";
		subtitle += `👥 ${subscriberCount}`;

		/** @type AlfredItem */
		const alfredItem = {
			title: `r/${subredditName}`,
			subtitle: subtitle,
			arg: subredditName,
			icon: { path: iconPath },
			mods: {
				cmd: {
					arg: `https://www.reddit.com/r/${subredditName}/`,
				},
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
				cmd: {
					arg: "https://news.ycombinator.com/",
				},
			},
		});
	}

	return JSON.stringify({ items: subreddits });
}
