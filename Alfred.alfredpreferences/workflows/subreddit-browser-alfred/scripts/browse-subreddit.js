#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

// INFO free API calls restricted to 10 per minute
// https://support.reddithelp.com/hc/en-us/articles/16160319875092-Reddit-Data-API-Wiki

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const subredditName = $.getenv("selected_subreddit");
	// INFO yes, curl is blocked only until you change the user agent, lol
	const curlCommand = `curl -sL -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/${subredditName}/new.json"`;
	const response = JSON.parse(app.doShellScript(curlCommand));

	let iconPath = `${$.getenv("alfred_workflow_data")}/${subredditName}.png`;
	if (!fileExists(iconPath)) iconPath = "icon.png"; // not cached

	// e.g., too many requests
	if (response.error) {
		return JSON.stringify({
			items: [{ title: response.message, subtitle: response.error }],
		});
	}

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
				cmd: {
					arg: subredditName,
				}
			},
		};
	});
	return JSON.stringify({ items: redditPosts });
}
