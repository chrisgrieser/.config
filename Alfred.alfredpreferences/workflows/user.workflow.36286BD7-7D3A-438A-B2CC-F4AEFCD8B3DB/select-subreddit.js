#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));


/** @param {string} subredditName */
function cacheSubredditIcon(subredditName) {
		const basename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -vasename.length);
		Application("Finder").make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: basename },
		});
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
			const iconPath = `${$.getenv("alfred_workflow_data")}/${subredditName}.png`;
			if (!fileExists(iconPath)) cacheSubredditIcon(subredditName);

			return {
				title: `r/${subredditName}`,
				arg: subredditName,
				icon: { path: iconPath },
			};
		});
	return JSON.stringify({ items: subreddits });
}
