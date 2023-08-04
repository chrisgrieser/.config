#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────
// CONFIG

const cacheAgeThreshold = parseInt($.getenv("cache_age_threshold")) || 15;
const oldReddit = $.getenv("use_old_reddit") === "1" ? "old" : "www";
const useDstillAi = $.getenv("use_dstill_ai") === "1";

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

function getHackernewsPosts() {
	// INFO https://hn.algolia.com/api/
	// alternative "https://hacker-news.firebaseio.com/v0/topstories.json";
	const url = "https://hn.algolia.com/api/v1/search_by_date?tags=front_page&hitsPerPage=50";
	const response = app.doShellScript(`curl -sL "${url}"`);
	if (!response) {
		console.log(`Error: No response from ${url}`);
		return;
	}

	/** @type AlfredItem[] */
	const hits = JSON.parse(response).hits.map((/** @type {hackerNewsItem} */ item) => {
		const externalUrl = item.url;
		const commentUrl = useDstillAi
			? "https://dstill.ai/hackernews/item/" + item.objectID
			: "https://news.ycombinator.com/item?id=" + item.objectID;

		// filter out jobs
		if (item._tags.some((tag) => tag === "job")) return {};

		let category = item._tags
			.find((tag) => tag === "show_hn" || tag === "ask_hn")
			.replace("show_hn", "Show HN")
			.replace("ask_hn", "Ask HN");
		category = category ? `[${category}]` : "";
		const comments = item.num_comments || 0;
		const subtitle = `${item.points}↑  ${comments}●  ${category}`;

		return {
			title: item.title,
			subtitle: subtitle,
			arg: commentUrl,
			icon: { path: "hackernews.png" },
			mods: {
				// pass current subreddit to determine next subreddit
				cmd: { arg: "hackernews" },
				shift: {
					arg: externalUrl,
				},
			},
		};
	});

	return hits;
}

//──────────────────────────────────────────────────────────────────────────────

/** @typedef {object} redditPost
 * @property {string} kind
 * @property {object} data
 * @property {string} data.subreddit
 * @property {string} data.title
 * @property {string} data.name
 * @property {boolean} data.is_reddit_media_domain
 * @property {string} data.link_flair_text
 * @property {number} data.score
 * @property {boolean} data.is_self
 * @property {string} data.domain
 * @property {null} data.view_count
 * @property {boolean} data.archived
 * @property {boolean} data.over_18
 * @property {string} data.id
 * @property {string} data.author
 * @property {null} data.discussion_type
 * @property {number} data.num_comments
 * @property {string} data.permalink
 * @property {boolean} data.stickied
 * @property {string} data.url
 * @property {number} data.num_crossposts
 * @property {string} data.media.type
 */

/** @param {string} subredditName */
function getRedditPosts(subredditName) {
	// HACK curl is blocked only until you change the user agent, lol
	const curlCommand = `curl -sL -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/${subredditName}/new.json"`;
	const response = JSON.parse(app.doShellScript(curlCommand));
	if (response.error) {
		console.log(`Error ${response.error}: ${response.message}`);
		return;
	}

	let iconPath = `${$.getenv("alfred_workflow_data")}/${subredditName}.png`;
	if (!fileExists(iconPath)) iconPath = "icon.png"; // not cached

	/** @type AlfredItem[] */
	const redditPosts = response.data.children.map((/** @type {redditPost} */ data) => {
		const item = data.data;
		const category = item.link_flair_text ? `[${item.link_flair_text}]` : "";
		const comments = item.num_comments || 0;
		const subtitle = `${item.score}↑  ${comments}●  ${category}`;

		const commentUrl = `https://${oldReddit}.reddit.com${item.permalink}`;
		const externalUrl = item.url;
		const isOnReddit = item.domain.includes("redd.it") || item.domain.startsWith("self.");
		const emoji = isOnReddit ? "" : "🔗 ";

		return {
			title: emoji + item.title,
			subtitle: subtitle,
			arg: commentUrl,
			icon: { path: iconPath },
			mods: {
				// pass current "subreddit" to determine next subreddit
				cmd: { arg: subredditName },
				shift: {
					valid: !isOnReddit,
					arg: externalUrl,
					subtitle: isOnReddit ? "No external link" : "⇧: Open external link",
				},
			},
		};
	});
	return redditPosts;
}

//──────────────────────────────────────────────────────────────────────────────

// INFO free API calls restricted to 10 per minute
// https://support.reddithelp.com/hc/en-us/articles/16160319875092-Reddit-Data-API-Wiki

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// SELECT SUBREDDIT
	const topSubreddit = $.getenv("subreddits").split("\n")[0]; // only needed for first run
	const currentSubreddit = readFile($.getenv("alfred_workflow_cache") + "/current_subreddit");
	const selectedSubreddit = $.NSProcessInfo.processInfo.environment.objectForKey("selected_subreddit").js;
	const subredditName = selectedSubreddit || currentSubreddit || topSubreddit;
	if (subredditName !== currentSubreddit) {
		writeToFile($.getenv("alfred_workflow_cache") + "/current_subreddit", subredditName);
	}

	// CACHE
	const subredditCache = `${$.getenv("alfred_workflow_cache")}/${subredditName}.json`;
	let posts;
	if (!cacheIsOutdated(subredditCache)) {
		posts = JSON.parse(readFile(subredditCache));
		return JSON.stringify({ items: posts });
	}

	// MAIN
	if (subredditName === "hackernews") {
		console.log("Writing new cache for hackernews");
		posts = getHackernewsPosts();
	} else {
		console.log("Writing new cache for r/" + subredditName);
		posts = getRedditPosts(subredditName);
		if (!posts) {
			return JSON.stringify({ items: [{ title: "Error", subtitle: "No response from reddit API" }] });
		}
	}

	writeToFile(subredditCache, JSON.stringify(posts));
	return JSON.stringify({ items: posts });
}
