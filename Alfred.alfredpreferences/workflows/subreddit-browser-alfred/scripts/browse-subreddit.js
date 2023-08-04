#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────
// CONFIG

const cacheAgeThreshold = parseInt($.getenv("cache_age_threshold")) || 15;
const useOldReddit = $.getenv("use_old_reddit") === "1";

//──────────────────────────────────────────────────────────────────────────────

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
	ensureCacheFolderExists();
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeMins = (+new Date() - cacheObj.creationDate()) / 1000 / 60;
	return cacheAgeMins > cacheAgeThreshold;
}

//──────────────────────────────────────────────────────────────────────────────

// INFO free API calls restricted to 10 per minute
// https://support.reddithelp.com/hc/en-us/articles/16160319875092-Reddit-Data-API-Wiki

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const topSubreddit = $.getenv("subreddits").split("\n")[0]; // only needed for first run
	const currentSubreddit = readFile($.getenv("alfred_workflow_cache") + "/current_subreddit" ) 
	const selectedSubreddit = $.NSProcessInfo.processInfo.environment.objectForKey("selected_subreddit").js
	const subredditName = selectedSubreddit || currentSubreddit || topSubreddit;

	writeToFile($.getenv("alfred_workflow_cache") + "/current_subreddit", subredditName);

	const subredditCache = `${$.getenv("alfred_workflow_cache")}/${subredditName}.json`;
	let response = {};

	if (cacheIsOutdated(subredditCache)) {
		console.log("Writing new cache for r/" + subredditName);

		// INFO yes, curl is blocked only until you change the user agent, lol
		const curlCommand = `curl -sL -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/${subredditName}/new.json"`;
		const responseStr = app.doShellScript(curlCommand);
		response = JSON.parse(responseStr);

		if (response.error) {
			return JSON.stringify({ items: [{ title: response.message, subtitle: response.error }] });
		}
		writeToFile(subredditCache, responseStr);
	} else {
		console.log("Using existing cache for r/" + subredditName);
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
		const url = useOldReddit ? item.url.replace("www", "old") : item.url;

		return {
			title: item.title,
			subtitle: subtitle,
			arg: url,
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
