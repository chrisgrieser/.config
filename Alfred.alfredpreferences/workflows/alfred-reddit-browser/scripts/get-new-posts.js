#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function getSettings() {
	const minUpvotesSetting = Number.parseInt($.getenv("min_upvotes")) || 0;
	const pagesToRequest = Number.parseInt($.getenv("pages_to_request")) || 25;
	return {
		minUpvotes: Math.max(minUpvotesSetting, 0), // minimum of 0
		useOldReddit: $.getenv("use_old_reddit") === "1" ? "old" : "www",
		hnFrontendUrl: $.getenv("hackernews_frontend_url"),
		iconFolder: $.getenv("custom_subreddit_icons") || $.getenv("alfred_workflow_data"),
		sortType: $.getenv("sort_type") || "hot",
		hideStickied: $.getenv("hide_stickied") === "1",
		pagesToRequest: Math.min(Math.max(pagesToRequest, 5), 100),
	};
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

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

/** @param {AlfredItem[]} oldItems */
// biome-ignore lint/correctness/noUnusedVariables: JXA import HACK
function getHackernewsPosts(oldItems) {
	const opts = getSettings();

	// DOCS https://hn.algolia.com/api
	// alternative "https://hacker-news.firebaseio.com/v0/topstories.json";
	const url = `https://hn.algolia.com/api/v1/search_by_date?tags=front_page&hitsPerPage=${opts.pagesToRequest}`;
	const response = app.doShellScript(`curl -sL "${url}"`);
	if (!response) {
		console.log(`Error: No response from ${url}`);
		return;
	}

	const oldUrls = oldItems.map((item) => item.arg);
	const oldTitles = oldItems.map((item) => item.title);

	/** @type{AlfredItem[]} */
	const hits = JSON.parse(response).hits.reduce(
		(/** @type {AlfredItem[]} */ acc, /** @type {hackerNewsItem} */ item) => {
			if (item.points < opts.minUpvotes) return acc;

			const externalUrl = item.url || "";
			const commentUrl = opts.hnFrontendUrl + item.objectID;

			// filter out jobs
			if (item._tags.some((tag) => tag === "job")) return acc;

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
				quicklookurl: externalUrl || commentUrl,
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
 * @param {AlfredItem[]} oldItems
 */
// biome-ignore lint/correctness/noUnusedVariables: JXA import HACK
function getRedditPosts(subredditName, oldItems) {
	const opts = getSettings();

	// DOCS https://www.reddit.com/dev/api#GET_new
	// HACK changing user agent because reddit API does not like curl (lol)
	const curlCommand = `curl -sL -H "User-Agent: Chrome/115.0.0.0" \\
		"https://www.reddit.com/r/${subredditName}/${opts.sortType}.json?limit=${opts.pagesToRequest}"`;
	const response = JSON.parse(app.doShellScript(curlCommand));
	if (response.error) {
		console.log(`Error ${response.error}: ${response.message}`);
		return;
	}

	const oldUrls = oldItems.map((item) => item.arg);
	const oldTitles = oldItems.map((item) => item.title);

	let iconPath = `${opts.iconFolder}/${subredditName}.png`;
	if (!fileExists(iconPath)) iconPath = "icon.png"; // not cached

	/** @type{AlfredItem[]} */
	const redditPosts = response.data.children.reduce(
		(/** @type {AlfredItem[]} */ acc, /** @type {redditPost} */ data) => {
			const item = data.data;
			if (item.score < opts.minUpvotes) return acc;
			if (item.stickied && opts.hideStickied) return acc;

			const commentUrl = `https://${opts.useOldReddit}.reddit.com${item.permalink}`;
			const isOnReddit = item.domain.includes("redd.it") || item.domain.startsWith("self.");
			const externalUrl = isOnReddit ? "" : item.url;
			let postTypeIcon = "";
			if (!isOnReddit) postTypeIcon = "🔗 ";
			const quicklookUrl = externalUrl || commentUrl;

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
				.replaceAll("&amp;", "&");

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
