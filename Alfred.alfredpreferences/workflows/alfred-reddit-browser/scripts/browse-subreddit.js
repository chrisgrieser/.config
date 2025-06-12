#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
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
	const cacheAgeThresholdMins = Number.parseInt($.getenv("cache_age_threshold"));
	const cacheObj = Application("System Events").aliases[path];
	if (!cacheObj.exists()) return true;
	const cacheAgeMins = (Date.now() - +cacheObj.creationDate()) / 1000 / 60;
	return cacheAgeMins > cacheAgeThresholdMins;
}

/**
 * @param {string} firstPath
 * @param {string} secondPath
 * @returns {boolean} firstPathOlderThanSecond
 */
function olderThan(firstPath, secondPath) {
	const firstItem = Application("System Events").aliases[firstPath];
	if (!firstItem.exists()) return true;
	const secondItem = Application("System Events").aliases[secondPath];
	if (!secondItem.exists()) return false;
	const firstPathOlderThanSecond =
		+firstItem.modificationDate() - +secondItem.modificationDate() < 0;
	return firstPathOlderThanSecond;
}

//──────────────────────────────────────────────────────────────────────────────

function getSettings() {
	return {
		minUpvotes: Number.parseInt($.getenv("min_upvotes")),
		redditFrontend: $.getenv("reddit_frontend"),
		hnFrontendUrl: $.getenv("hackernews_frontend_url"),
		iconFolder: $.getenv("custom_subreddit_icons") || $.getenv("alfred_workflow_data"),
		sortType: $.getenv("sort_type") || "hot",
		hideStickied: $.getenv("hide_stickied") === "1",
		pagesToRequest: Number.parseInt($.getenv("pages_to_request")),
	};
}

/** @typedef {Object} hackerNewsItem
 * @property {string} objectID
 * @property {string} title
 * @property {string} url
 * @property {number} num_comments
 * @property {number} points
 * @property {string} author
 * @property {string[]} _tags
 */

/**
 * @param {AlfredItem[]} oldItems for marker for old posts
 * @returns {AlfredItem[]|string}}
 */
function getHackernewsPosts(oldItems) {
	const opts = getSettings();

	// DOCS https://hn.algolia.com/api
	// alternative "https://hacker-news.firebaseio.com/v0/topstories.json";
	const url = `https://hn.algolia.com/api/v1/search_by_date?tags=front_page&hitsPerPage=${opts.pagesToRequest}`;
	let response;
	const apiResponse = app.doShellScript(`curl -sL "${url}"`);
	try {
		response = JSON.parse(apiResponse);
	} catch (_error) {
		return `Error parsing JSON. curl response was: ${apiResponse}`;
	}

	const oldUrls = oldItems.map((item) => item.arg);
	const oldTitles = oldItems.map((item) => item.title);

	/** @type{AlfredItem[]} */
	const hits = response.hits.reduce(
		// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: okay here
		(/** @type {AlfredItem[]} */ acc, /** @type {hackerNewsItem} */ item) => {
			if (item.points < opts.minUpvotes) return acc;

			const externalUrl = item.url || "";
			const commentUrl = opts.hnFrontendUrl + item.objectID;

			// filter out jobs
			if (item._tags.some((tag) => tag === "job")) return acc;

			// prevent app store URLs auto-open `App Store.app`
			const externalUrlNotAppStore =
				externalUrl && !externalUrl.startsWith("https://apps.apple.com/");
			const quicklookUrl = externalUrlNotAppStore ? externalUrl : commentUrl;

			// age & visitation icon
			const postIsOld = oldUrls.includes(commentUrl);
			// HACK since visitation status is only stored as icon, the only way to
			// determine it is via checking for the respective icon
			const postIsVisited = postIsOld && oldTitles.includes("🟪 " + item.title);
			let ageIcon = "";
			if ($.getenv("age_icon") === "old" && postIsOld) ageIcon = "🕓 ";
			if ($.getenv("age_icon") === "new" && !postIsOld) ageIcon = "🆕 ";
			const visitationIcon = postIsVisited ? "🟪 " : "";

			// subtitle
			/** @type {string|undefined} */
			let category = item._tags.find((tag) => tag === "show_hn" || tag === "ask_hn");
			category = (category ? `[${category}]` : "")
				.replace("show_hn", "Show HN")
				.replace("ask_hn", "Ask HN");
			const comments = item.num_comments || 0;
			const subtitle = `${ageIcon}${item.points}↑  ${comments}●  ${category}`;

			/** @type{AlfredItem} */
			const post = {
				title: visitationIcon + item.title,
				subtitle: subtitle,
				arg: commentUrl,
				quicklookurl: quicklookUrl,
				icon: { path: "hackernews.png" },
				mods: {
					cmd: { arg: "next" },
					"cmd+shift": { arg: "prev" },
					shift: {
						arg: externalUrl,
						valid: Boolean(externalUrl),
						subtitle: externalUrl ? "⇧: Open External URL" : "⇧: ⛔ No External URL",
					},
				},
			};
			acc.push(post);
			return acc;
		},
		[],
	);

	return hits;
}

//──────────────────────────────────────────────────────────────────────────────

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
 * @property {boolean} data.stickied
 * @property {number} data.num_crossposts
 * @property {any} data.preview
 * @property {string} data.media.type
 */

// INFO free API calls restricted to 10 per minute
// https://support.reddithelp.com/hc/en-us/articles/16160319875092-Reddit-Data-API-Wiki

/**
 * @param {string} subredditName
 * @param {AlfredItem[]} oldItems for marker for old posts
 * @returns {AlfredItem[]|string}}
 */
function getRedditPosts(subredditName, oldItems) {
	const opts = getSettings();

	// DOCS https://www.reddit.com/dev/api#GET_new
	// SIC try `curl` with and without user agent, since sometimes one is
	// blocked, sometimes the other?
	const apiUrl = `https://www.reddit.com/r/${subredditName}/${opts.sortType}.json?limit=${opts.pagesToRequest}`;
	const userAgent = "Chrome/136.0.0.0";
	let curlCommand = `curl -sL -H "User-Agent: ${userAgent}" "${apiUrl}"`;
	let response;
	try {
		response = JSON.parse(app.doShellScript(curlCommand));
		if (response.error) {
			curlCommand = `curl -sL "${apiUrl}"`;
			response = JSON.parse(app.doShellScript(curlCommand));
			if (response.error) {
				const errorMsg = `Error ${response.error}: ${response.message}`;
				return errorMsg;
			}
		}
	} catch (_error) {
		console.log("Failed curl command: " + curlCommand);
		const apiResponse = app.doShellScript(curlCommand);
		try {
			curlCommand = `curl -sL "${apiUrl}"`;
			response = JSON.parse(apiResponse);
		} catch (_error) {
			console.log("Failed curl command: " + curlCommand);
			const errorMsg = `Error parsing JSON. curl response was: ${apiResponse}`;
			console.log(errorMsg);
			return errorMsg;
		}
	}

	const oldUrls = oldItems.map((item) => item.arg);
	const oldTitles = oldItems.map((item) => item.title);

	let iconPath = `${opts.iconFolder}/${subredditName}.png`;
	if (!fileExists(iconPath)) iconPath = "icon.png"; // not cached

	/** @type{AlfredItem[]} */
	const redditPosts = response.data.children.reduce(
		// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: okay here
		(/** @type {AlfredItem[]} */ acc, /** @type {redditPost} */ data) => {
			const item = data.data;
			if (item.score < opts.minUpvotes) return acc;
			if (item.stickied && opts.hideStickied) return acc;

			const commentUrl = `https://${opts.redditFrontend}${item.permalink}`;
			const isOnReddit = item.domain.includes("redd.it") || item.domain.startsWith("self.");
			const externalUrl = isOnReddit ? "" : item.url;
			let postTypeIcon = "";
			if (!isOnReddit) postTypeIcon = "🔗 ";

			// prevent app store URLs auto-open `App Store.app`
			const externalUrlNotAppStore =
				externalUrl && !externalUrl.startsWith("https://apps.apple.com/");
			const quicklookUrl = externalUrlNotAppStore ? externalUrl : commentUrl;

			// age & visited icon
			const postIsOld = oldUrls.includes(commentUrl);
			let ageIcon = "";
			const postIsVisited = postIsOld && oldTitles.includes("🟪 " + item.title);
			if ($.getenv("age_icon") === "old" && postIsOld) ageIcon = "🕓 ";
			if ($.getenv("age_icon") === "new" && !postIsOld) ageIcon = "🆕 ";
			const visitedIcon = postIsVisited ? "🟪 " : "";

			// subtitle
			const stickyIcon = item.stickied ? "📌 " : "";
			let category = item.link_flair_text ? `[${item.link_flair_text}]` : "";
			if (item.over_18) category += " [NSFW]";
			const comments = item.num_comments ?? 0;
			const crossposts = item.num_crossposts ? ` ${item.num_crossposts}↗` : "";
			const subtitle = `${stickyIcon}${postTypeIcon}${ageIcon}${item.score}↑  ${comments}● ${crossposts} ${category}`;

			const cleanTitle = item.title
				.replaceAll("&lt;", "<")
				.replaceAll("&gt;", ">")
				.replaceAll("&amp;", "&")
				.trim();

			/** @type{AlfredItem} */
			const post = {
				title: visitedIcon + cleanTitle,
				subtitle: subtitle,
				arg: commentUrl,
				icon: { path: iconPath },
				quicklookurl: quicklookUrl,
				mods: {
					cmd: { arg: "next" },
					"cmd+shift": { arg: "prev" },
					shift: {
						valid: !isOnReddit,
						arg: externalUrl,
						subtitle: isOnReddit ? "⇧: ⛔ No External URL" : "⇧: Open External URL",
					},
				},
			};
			acc.push(post);
			return acc;
		},
		[],
	);
	return redditPosts;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// DETERMINE SUBREDDIT
	const subreddits = $.getenv("subreddits")
		.trim()
		.replace(/^\/?r\//gm, "") // can be `r/` or `/r/` https://www.alfredforum.com/topic/20813-reddit-browser/page/2/#comment-114645// can be r/ or /r/ https://www.alfredforum.com/topic/20813-reddit-browser/page/2/#comment-114645
		.split("\n");
	if ($.getenv("add_hackernews") === "1") subreddits.push("hackernews");
	const cachePath = $.getenv("alfred_workflow_cache");

	/** @type {string?} */
	let prevSubreddit = readFile(cachePath + "/current_subreddit");
	// if user removed subreddit from config, do not display it
	if (!subreddits.includes(prevSubreddit)) prevSubreddit = null;
	const selectedWithAlfred =
		$.NSProcessInfo.processInfo.environment.objectForKey("selected_subreddit").js;
	const subredditName = selectedWithAlfred || prevSubreddit || subreddits[0];

	ensureCacheFolderExists();
	writeToFile(cachePath + "/current_subreddit", subredditName);

	// READ POSTS FROM CACHE
	const pathOfThisWorkflow =
		$.getenv("alfred_preferences") + "/workflows/" + $.getenv("alfred_workflow_uid");
	const subredditCache = `${cachePath}/${subredditName}.json`;
	const refreshIntervalPassed = cacheIsOutdated(subredditCache);
	const userPrefsUnchanged = olderThan(`${pathOfThisWorkflow}/prefs.plist`, subredditCache);
	const cachedItems = fileExists(subredditCache) ? JSON.parse(readFile(subredditCache)) : [];
	if (!refreshIntervalPassed && userPrefsUnchanged) {
		return JSON.stringify({
			variables: { cacheWasUpdated: "false" }, // Alfred vars always strings
			skipknowledge: true, // workflow handles order to remember reading positions
			items: cachedItems,
		});
	}

	// REQUEST NEW POSTS FROM API
	console.log(`Writing new cache for "${subredditName}"`);
	const posts =
		subredditName === "hackernews"
			? getHackernewsPosts(cachedItems)
			: getRedditPosts(subredditName, cachedItems);

	// GUARD Error or no posts left after filtering
	if (typeof posts === "string") {
		const blockedByNs = posts.includes("blocked by network security");
		const errorMsg = blockedByNs ? "You have been blocked by network security." : posts;
		const info = blockedByNs
			? "Usually, the workflow will work again in a few hours."
			: "See debugging console for details.";
		return JSON.stringify({
			items: [
				{
					title: errorMsg,
					subtitle: info,
					valid: false,
					mods: { cmd: { valid: true } },
				},
				{
					title: "Open subreddit in the browser",
					subtitle: "r/" + subredditName,
					arg: `https://www.reddit.com/r/${subredditName}`,
				},
			],
		});
	}
	if (posts.length === 0) {
		const msg = "No posts higher than minimum upvote count.";
		return JSON.stringify({ items: [{ title: msg, valid: false }] });
	}

	// WRITE CACHE & RETURN POSTS
	writeToFile(subredditCache, JSON.stringify(posts));
	return JSON.stringify({
		variables: { cacheWasUpdated: "true" }, // Alfred vars always strings
		items: posts,
	});
}
