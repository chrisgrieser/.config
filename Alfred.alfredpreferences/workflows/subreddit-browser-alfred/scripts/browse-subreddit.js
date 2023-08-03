#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

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

/** @param {string} path */
function cacheIsOutdated(path) {
	const cacheObj = Application("System Events").aliases[path];
	const cacheAgeMins = (+new Date() - cacheObj.creationDate()) / 1000 / 60;
	const cacheAgeThreshold = parseInt($.getenv("cache_age_threshold")) || 15;
	return cacheAgeMins > cacheAgeThreshold;
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

// INFO free API calls restricted to 10 per minute
// https://support.reddithelp.com/hc/en-us/articles/16160319875092-Reddit-Data-API-Wiki

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// search passed subreddit, or if called directly, the top subreddit
	const topSubreddit = $.getenv("subreddits").split("\n")[0];
	const subredditName =
		$.NSProcessInfo.processInfo.environment.objectForKey("selected_subreddit").js || topSubreddit;

	const subredditCache = `${$.getenv("alfred_workflow_cache") + subredditName}.json`;
	let response = {};

	if (!fileExists(subredditCache) || cacheIsOutdated(subredditCache)) {
		console.log("Writing new cache for " + subredditName);

		// INFO yes, curl is blocked only until you change the user agent, lol
		const curlCommand = `curl -sL -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/${subredditName}/new.json"`;
		const responseStr = app.doShellScript(curlCommand);
		response = JSON.parse(responseStr);

		if (response.error) {
			return JSON.stringify({ items: [{ title: response.message, subtitle: response.error }] });
		}
		ensureCacheFolderExists()
		writeToFile(subredditCache, responseStr);
	} else {
		console.log("Using existing cache for " + subredditName);
		response = JSON.parse(readFile(subredditCache));
	}

	let iconPath = `${$.getenv("alfred_workflow_data")}/${subredditName}.png`;
	if (!fileExists(iconPath)) iconPath = "icon.png"; // not cached

	/** @type AlfredItem[] */
	const redditPosts = response.data.children.map((/** @type {{ data: any; }} */ data) => {
		const item = data.data;
		const comments = item.num_comments;
		const category = item.link_flair_text ? `[${item.link_flair_text}]` : "";
		const subtitle = `${item.score}↑  ${comments}●  ${category}`;

		return {
			title: item.title,
			subtitle: subtitle,
			arg: item.url,
			icon: { path: iconPath },
			mods: {
				shift: {
					valid: false,
					subtitle: `author: ${item.author}`,
				},
				cmd: { arg: subredditName }, // next subreddit
			},
		};
	});
	return JSON.stringify({ items: redditPosts });
}
