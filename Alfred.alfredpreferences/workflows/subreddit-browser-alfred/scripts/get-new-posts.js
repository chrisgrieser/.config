#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const oldReddit = $.getenv("use_old_reddit") === "1" ? "old" : "www";
const useDstillAi = $.getenv("use_dstill_ai") === "1";
const iconFolder = $.getenv("custom_subreddit_icons") || $.getenv("alfred_workflow_data");

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
// rome-ignore lint/correctness/noUnusedVariables: JXA import HACK
function getHackernewsPosts(oldItems) {
	// INFO https://hn.algolia.com/api/
	// alternative "https://hacker-news.firebaseio.com/v0/topstories.json";
	const hitsToRequest = 30;
	const url = `https://hn.algolia.com/api/v1/search_by_date?tags=front_page&hitsPerPage=${hitsToRequest}`;
	const response = app.doShellScript(`curl -sL "${url}"`);
	if (!response) {
		console.log(`Error: No response from ${url}`);
		return;
	}

	const oldUrls = oldItems.map((item) => item.arg);
	const oldTitles = oldItems.map((item) => item.title);

	/** @type{AlfredItem[]} */
	const hits = JSON.parse(response).hits.map((/** @type {hackerNewsItem} */ item) => {
		const externalUrl = item.url || "";
		const commentUrl = useDstillAi
			? "https://dstill.ai/hackernews/item/" + item.objectID
			: "https://news.ycombinator.com/item?id=" + item.objectID;

		// filter out jobs
		if (item._tags.some((tag) => tag === "job")) return {};

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
		category = (category ? `[${category}]` : "").replace("show_hn", "Show HN").replace("ask_hn", "Ask HN");
		const comments = item.num_comments || 0;
		const subtitle = `${ageIcon}${item.points}↑  ${comments}●  ${category}`;

		/** @type{AlfredItem} */
		const post = {
			title: visitationIcon + item.title,
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
 * @property {number} data.num_crossposts
 * @property {any} data.preview
 * @property {string} data.media.type
 */

/**
 * @param {string} subredditName
 * @param {AlfredItem[]} oldItems
 */
// rome-ignore lint/correctness/noUnusedVariables: JXA import HACK
function getRedditPosts(subredditName, oldItems) {
	// INFO free API calls restricted to 10 per minute
	// https://support.reddithelp.com/hc/en-us/articles/16160319875092-Reddit-Data-API-Wiki

	// HACK changing user agent because reddit API does not like curl (lol)
	const curlCommand = `curl -sL -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/${subredditName}/new.json"`;
	const response = JSON.parse(app.doShellScript(curlCommand));
	if (response.error) {
		console.log(`Error ${response.error}: ${response.message}`);
		return;
	}

	const oldUrls = oldItems.map((item) => item.arg);
	const oldTitles = oldItems.map((item) => item.title);

	let iconPath = `${iconFolder}/${subredditName}.png`;
	if (!fileExists(iconPath)) iconPath = "icon.png"; // not cached

	const redditPosts = response.data.children.map((/** @type {redditPost} */ data) => {
		const item = data.data;

		const commentUrl = `https://${oldReddit}.reddit.com${item.permalink}`;
		const isOnReddit = item.domain.includes("redd.it") || item.domain.startsWith("self.");
		const externalUrl = isOnReddit ? "" : item.url;
		const imageUrl = item.preview?.images[0]?.source?.url;
		let postTypeIcon = ""
		if (imageUrl) postTypeIcon = "📷 "
		else if (!isOnReddit) postTypeIcon = "🔗 "
		const quicklookUrl = imageUrl || externalUrl || commentUrl;

		// age icon
		const postIsOld = oldUrls.includes(commentUrl);
		let ageIcon = "";
		const postIsVisited = postIsOld && oldTitles.includes("🟪 " + item.title);
		if ($.getenv("age_icon") === "old" && postIsOld) ageIcon = "🕓 ";
		if ($.getenv("age_icon") === "new" && !postIsOld) ageIcon = "🆕 ";
		const visitationIcon = postIsVisited ? "🟪 " : "";

		// subtitle
		let category = item.link_flair_text ? `[${item.link_flair_text}]` : "";
		if (item.over_18) category += " [NSFW]";
		const comments = item.num_comments || 0;
		const crossposts = item.num_crossposts ? ` ${item.num_crossposts}↗` : "";
		const subtitle = `${postTypeIcon}${ageIcon}${item.score}↑  ${comments}● ${crossposts} ${category}`;

		/** @type{AlfredItem} */
		const post = {
			title: visitationIcon + item.title,
			subtitle: subtitle,
			arg: commentUrl,
			icon: { path: iconPath },
			quicklookurl: quicklookUrl,
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
