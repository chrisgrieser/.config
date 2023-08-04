#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const iconFolder = $.getenv("custom_subreddit_icons") || $.getenv("alfred_workflow_data");

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

/**
 * @param {string} iconPath
 * @param {string} subredditName
 */
function cacheSubredditIcon(iconPath, subredditName) {
	const redditApiCall = `curl -sL -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/${subredditName}/about.json"`;
	const subredditInfo = JSON.parse(app.doShellScript(redditApiCall));
	if (subredditInfo.error) {
		console.log(`${subredditInfo.error}: ${subredditInfo.message}`);
		return subredditInfo.error;
	}

	// for some subreddits saved as icon_img, for others as community_icon
	let onlineIcon = subredditInfo.data.icon_img || subredditInfo.data.community_icon;
	if (!onlineIcon) return; // has no icon
	onlineIcon = onlineIcon.replace(/\?.*$/, ""); // clean url for curl

	app.doShellScript(`curl -sL "${onlineIcon}" --create-dirs --output "${iconPath}"`);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const subreddits = $.getenv("subreddits")
		.split("\n")
		.map((subredditName) => {
			let subtitle = "";

			// cache subreddit image
			let iconPath = `${iconFolder}/${subredditName}.png`;
			if (!fileExists(iconPath)) {
				const error = cacheSubredditIcon(iconPath, subredditName);
				if (error) console.log("Error:", error);
				// if icon cannot be cached, use default icon
				if (!fileExists(iconPath)) iconPath = "icon.png";

				// only check for subreddit existence on icon caching, to reduce
				// number of requests
				if (error === 404) subtitle = "⚠️ subreddit not found";
			}

			return {
				title: `r/${subredditName}`,
				subtitle: subtitle,
				arg: subredditName,
				icon: { path: iconPath },
			};
		});

	// add hackernews as pseudo-subreddit
	const addHackernews = $.getenv("add_hackernews") === "1";
	if (addHackernews) {
		subreddits.push({
			title: "Hackernews",
			arg: "hackernews",
			icon: { path: "hackernews.png" },
		});
	}

	return JSON.stringify({ items: subreddits });
}
