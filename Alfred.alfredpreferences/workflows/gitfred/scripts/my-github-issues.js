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

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: alfred_run
function run() {
	const resultsNumber = 50; // api allows up to 100
	const username = $.getenv("github_username");
	const apiURL = `https://api.github.com/search/issues?q=involves:${username}&per_page=${resultsNumber}`;

	const issues = JSON.parse(app.doShellScript(`curl -sL "${apiURL}"`)).items.map(
		(/** @type {GithubIssue} */ item) => {
			const issueAuthor = item.user.login;
			const authoredByMe = issueAuthor === username;

			const isPR = Boolean(item.pull_request);
			const merged = Boolean(item.pull_request?.merged_at);
			const title = item.title;
			const repo = (item.repository_url.match(/[^/]+$/) || "")[0];
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
				quicklookurl: item.html_url,
			};
		},
	);
	return JSON.stringify({
		items: issues,
		cache: {
			seconds: 150, // fast to pick up recently created issues
			loosereload: true,
		},
	});
}
