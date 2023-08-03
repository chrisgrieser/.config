#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// INFO free API calls restricted to 10 per minute
// https://support.reddithelp.com/hc/en-us/articles/16160319875092-Reddit-Data-API-Wiki

// INFO yes, curl is blocked only until you change the user agent
const baseURL = "https://www.reddit.com/r/neovim/";
const curlCommand = 'curl -H "User-Agent: Chrome/115.0.0.0" "https://www.reddit.com/r/neovim/new.json"';

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const redditPosts = JSON.parse(app.doShellScript(curlCommand)).data.children.map(
		(/** @type {{ data: any; }} */ data) => {
			const item = data.data;
			const title = item.title;

			const url = baseURL + item.url;
			return {
				title: title,
				subtitle: url,
				arg: url,
			};
		},
	);
	return JSON.stringify({ items: redditPosts });
}
