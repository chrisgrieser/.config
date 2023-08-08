#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────
// CONFIG

const cacheAgeThreshold = parseInt($.getenv("cache_age_threshold")) || 15;
const oldReddit = $.getenv("use_old_reddit") === "1" ? "old" : "www";
const useDstillAi = $.getenv("use_dstill_ai") === "1";
const iconFolder = $.getenv("custom_subreddit_icons") || $.getenv("alfred_workflow_data");

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

/** @typedef {Object} hackerNewsItem
 * @property {string} objectID
 * @property {string} title
 * @property {string} url
 * @property {number} num_comments
 * @property {number} points
 * @property {string} author
 * @property {string[]} _tags
 */

/** @param {string[]} oldUrls */
function getHackernewsPosts(oldUrls) {
	// INFO https://hn.algolia.com/api/
	// alternative "https://hacker-news.firebaseio.com/v0/topstories.json";
	const hitsToRequest = 30;
	const url = `https://hn.algolia.com/api/v1/search_by_date?tags=front_page&hitsPerPage=${hitsToRequest}`;
	const response = app.doShellScript(`curl -sL "${url}"`);
	if (!response) {
		console.log(`Error: No response from ${url}`);
		return;
	}

	/** @type{AlfredItem[]} */
	const hits = JSON.parse(response).hits.map((/** @type {hackerNewsItem} */ item) => {
		const externalUrl = item.url;
		const commentUrl = useDstillAi
			? "https://dstill.ai/hackernews/item/" + item.objectID
			: "https://news.ycombinator.com/item?id=" + item.objectID;

		// filter out jobs
		if (item._tags.some((tag) => tag === "job")) return {};

		// age icon
		const postIsOld = oldUrls.includes(commentUrl)
		let ageIcon = ""
		if ($.getenv("age_icon") === "old" && postIsOld) ageIcon = "🕓 "
		if ($.getenv("age_icon") === "new" && !postIsOld) ageIcon = "🆕 "

		// subtitle
		let category = item._tags.find((tag) => tag === "show_hn" || tag === "ask_hn");
		category = (category ? `[${category}]` : "").replace("show_hn", "Show HN").replace("ask_hn", "Ask HN");
		const comments = item.num_comments || 0;
		const subtitle = `${ageIcon}${item.points}↑  ${comments}●  ${category}`;

		/** @type{AlfredItem} */
		const post = {
			title: item.title,
			subtitle: subtitle,
			arg: commentUrl,
			icon: { path: "hackernews.png" },
			mods: {
				cmd: { arg: "next" },
				["cmd+shift"]: { arg: "prev" },
				shift: { arg: externalUrl },
			},
		};
		return post;
	});

	return hits;
}

/** @typedef {object} redditPost
 * @property {string} kind
 * @property {object} data
 * @property {string} data.subreddit
 * @property {string} data.title
 * @property {boolean} data.is_reddit_media_domain
 * @property {string} data.link_flair_text
 * @property {number} data.score
 * @property {boolean} data.is_self
 * @property {string} data.domain
 * @property {boolean} data.over_18
 * @property {string} data.author
 * @property {number} data.num_comments
 * @property {string} data.permalink
 * @property {string} data.url
 * @property {number} data.num_crossposts
 * @property {string} data.media.type
 */

/**
 * @param {string} subredditName
 * @param {string[]} oldUrls
 */
function getRedditPosts(subredditName, oldUrls) {
	// INFO free API calls restricted to 10 per minute
	// https://support.reddithelp.com/hc/en-us/articles/16160319875092-Reddit-Data-API-Wiki

	// HACK changing user agent because reddit API does not like curl (lol)
	const curlCommand = `curl -sL -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/${subredditName}/new.json"`;
	const response = JSON.parse(app.doShellScript(curlCommand));
	if (response.error) {
		console.log(`Error ${response.error}: ${response.message}`);
		return;
	}

	let iconPath = `${iconFolder}/${subredditName}.png`;
	if (!fileExists(iconPath)) iconPath = "icon.png"; // not cached

	const redditPosts = response.data.children.map((/** @type {redditPost} */ data) => {
		const item = data.data;

		const commentUrl = `https://${oldReddit}.reddit.com${item.permalink}`;
		const externalUrl = item.url;
		const isOnReddit = item.domain.includes("redd.it") || item.domain.startsWith("self.");
		const emoji = isOnReddit ? "" : "🔗 ";

		// age icon
		const postIsOld = oldUrls.includes(commentUrl)
		let ageIcon = ""
		if ($.getenv("age_icon") === "old" && postIsOld) ageIcon = "🕓 "
		if ($.getenv("age_icon") === "new" && !postIsOld) ageIcon = "🆕 "

		// subtitle
		let category = item.link_flair_text ? `[${item.link_flair_text}]` : "";
		if (item.over_18) category += " [NSFW]";
		const comments = item.num_comments || 0;
		const crossposts = item.num_crossposts ? ` ${item.num_crossposts}↗` : "";
		const subtitle = `${ageIcon}${item.score}↑  ${comments}● ${crossposts} ${category}`;

		/** @type{AlfredItem} */
		const post = {
			title: emoji + item.title,
			subtitle: subtitle,
			arg: commentUrl,
			icon: { path: iconPath },
			mods: {
				cmd: { arg: "next" },
				["cmd+shift"]: { arg: "prev" },
				shift: {
					valid: !isOnReddit,
					arg: externalUrl,
					subtitle: isOnReddit ? "No external link" : "⇧: Open external link",
				},
			},
		};
		return post;
	});
	return redditPosts;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// determine subreddit
	const topSubreddit = $.getenv("subreddits").split("\n")[0]; // only needed for first run
	const curSubreddit = readFile($.getenv("alfred_workflow_cache") + "/current_subreddit");
	const selectedSubreddit = $.NSProcessInfo.processInfo.environment.objectForKey("selected_subreddit").js;
	const subredditName = selectedSubreddit || curSubreddit || topSubreddit;
	if (subredditName !== curSubreddit) {
		writeToFile($.getenv("alfred_workflow_cache") + "/current_subreddit", subredditName);
	}

	// read posts from cache
	const subredditCache = `${$.getenv("alfred_workflow_cache")}/${subredditName}.json`;
	let posts;
	if (!cacheIsOutdated(subredditCache)) {
		posts = JSON.parse(readFile(subredditCache));
		return JSON.stringify({
			variables: { cache_was_updated: "false" }, // Alfred vars always strings
			skipknowledge: true, // workflow handles order to remember reading positions
			items: posts,
		});
	}

	// marker for old posts
	const oldUrls = fileExists(subredditCache)
		? JSON.parse(readFile(subredditCache)).map((/** @type {AlfredItem} */ item) => item.arg)
		: [];

	// request new posts from API
	if (subredditName === "hackernews") {
		console.log("Writing new cache for hackernews");
		posts = getHackernewsPosts(oldUrls);
	} else {
		console.log("Writing new cache for r/" + subredditName);
		posts = getRedditPosts(subredditName, oldUrls);
		if (!posts) {
			return JSON.stringify({ items: [{ title: "Error", subtitle: "No response from reddit API" }] });
		}
	}
	writeToFile(subredditCache, JSON.stringify(posts));
	return JSON.stringify({
		variables: { cache_was_updated: "true" }, // Alfred vars always strings
		items: posts,
	});
}
