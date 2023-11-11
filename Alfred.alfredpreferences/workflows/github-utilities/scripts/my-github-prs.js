#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: alfred_run
function run() {
	const resultsNumber = $.getenv("results_number");
	const username = $.getenv("github_username");
	const apiURL = `https://api.github.com/search/issues?q=author:${username}+is:pr+is:open&per_page=${resultsNumber}`;

	const openPrs = JSON.parse(app.doShellScript(`curl -sL "${apiURL}"`)).items.map(
		(/** @type {GithubIssue} */ item) => {

			const title = item.title;
			const repo = item.repository_url.match(/[^/]+$/)[0];
			const comments = item.comments > 0 ? "💬 " + item.comments.toString() : "";

			return {
				title: title,
				subtitle: `#${item.number}  ${repo}   ${comments}`,
				match: alfredMatcher(title) + alfredMatcher(repo),
				arg: item.html_url,
			};
		},
	);
	return JSON.stringify({ items: openPrs });
}
