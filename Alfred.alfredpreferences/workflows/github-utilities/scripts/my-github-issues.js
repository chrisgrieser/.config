#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: alfred_run
function run() {
	const resultsNumber = $.getenv("results_number");
	const username = $.getenv("github_username");

	// search issues or PRs
	const mode = $.getenv("alfred_workflow_keyword") === "ghi" ? "issues" : "pr";

	// DOCS https://gist.github.com/bonniss/4f0de4f599708c5268134225dda003e0
	const apiURL = `https://api.github.com/search/issues?q=user:${username}&per_page=${resultsNumber}`;

	//───────────────────────────────────────────────────────────────────────────


	const alfredItems = JSON.parse(app.doShellScript(`curl -sL "${apiURL}"`)).items.map((/** @type {GithubIssue} */ item) => {
		const issueAuthor = item.user.login;
		const authoredByMe = issueAuthor === username;

		const isPR = Boolean(item.pull_request);
		const merged = Boolean(item.pull_request?.merged_at);
		const title = item.title;
		const repo = item.repository_url.match(/[^/]+$/)[0];
		const comments = item.comments > 0 ? "💬 " + item.comments.toString() : "";

		let icon = authoredByMe ? "🚩 " : "";
		if (item.state === "open" && isPR) icon += "🟩 ";
		else if (item.state === "closed" && isPR && merged) icon += "🟪 ";
		else if (item.state === "closed" && isPR && !merged) icon += "🟥 ";
		else if (item.state === "closed" && !isPR) icon += "🟣 ";
		else if (item.state === "open" && !isPR) icon += "🟢 ";
		if (title.toLowerCase().includes("request") || title.includes("FR")) icon += "🙏 ";
		if (title.toLowerCase().includes("bug")) icon += "🪲 ";

		let matcher = alfredMatcher(item.title) + " " + alfredMatcher(repo) + " " + item.state;
		if (isPR) matcher += " pr";
		else matcher += " issue";

		return {
			title: icon + title,
			subtitle: `#${item.number}  ${repo}   ${comments}`,
			match: matcher,
			arg: item.html_url,
			mods: {
				shift: {
					subtitle: `⇧: Search Issues (${item.open_issues} open)`,
					arg: item.full_name,
				},
			},
		};
	});
	return JSON.stringify({ items: alfredItems });
}
