#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ");
}

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: alfred_run
function run() {
	const username = $.getenv("github_username");

	// DOCS https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#list-issues-assigned-to-the-authenticated-user--parameters
	const apiUrl = `https://api.github.com/search/issues?q=involves:${username}&sort=updated&per_page=100`;
	const response = httpRequest(apiUrl);
	if (!response) {
		return JSON.stringify({
			items: [{ title: "No response from GitHub.", subtitle: "Try again later.", valid: false }],
		});
	}

	const issues = JSON.parse(response).items.map((/** @type {GithubIssue} */ item) => {
		const issueAuthor = item.user.login;
		const repo = (item.repository_url.match(/[^/]+$/) || "")[0];
		const comments = item.comments > 0 ? "💬 " + item.comments.toString() : "";
		const labels = item.labels.map((label) => `[${label.name}]`).join(" ");

		const subtitle = [`#${item.number}`, repo, comments.toString(), labels]
			.filter(Boolean)
			.join("   ");

		// ICON
		let icon = issueAuthor === username ? "✏️ " : "";
		if (item.pull_request) {
			if (item.draft) icon += "⬜ ";
			else if (item.state === "open") icon += "🟩 ";
			else if (item.pull_request.merged_at) icon += "🟪 ";
			else icon += "🟥 ";
		} else {
			if (item.state === "open") icon += "🟢 ";
			else if (item.state_reason === "not_planned") icon += "⚪ ";
			else if (item.state_reason === "completed") icon += "🟣 ";
		}

		let matcher = alfredMatcher(item.title) + " " + alfredMatcher(repo) + " " + item.state;
		if (item.pull_request) matcher += " pr";
		else matcher += " issue";
		if (item.draft) matcher += " draft";

		return {
			title: icon + item.title,
			subtitle: subtitle,
			match: matcher,
			arg: item.html_url,
			quicklookurl: item.html_url,
		};
	});
	return JSON.stringify({
		items: issues,
		cache: {
			seconds: 150, // fast to pick up recently created issues
			loosereload: true,
		},
	});
}
