#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

/** @param {string} subredditName */
function cacheSubredditIcon(subredditName) {
	const iconPath = `${$.getenv("alfred_workflow_data")}/${subredditName}.png`;
	const redditApiCall = `curl -sL -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/${subredditName}/about.json"`;
	const subredditInfo = JSON.parse(app.doShellScript(redditApiCall));
	if (subredditInfo.error) {
		console.log(`${subredditInfo.error}: ${subredditInfo.message}`);
		return;
	}

	// for some subreddits saved as icon_img, for others as community_icon
	const onlineIcon = subredditInfo.data.icon_img || subredditInfo.data.community_icon.replace(/\?.*$/, "");
	if (!onlineIcon) return;

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
			// cache subreddit image
			let iconPath = `${$.getenv("alfred_workflow_data")}/${subredditName}.png`;
			if (!fileExists(iconPath)) {
				cacheSubredditIcon(subredditName);
				// cannot be cached
				if (!fileExists(iconPath)) iconPath = "icon.png";
			}

			return {
				title: `r/${subredditName}`,
				arg: subredditName,
				icon: { path: iconPath },
			};
		});
	return JSON.stringify({ items: subreddits });
}
