#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const repoID = $.getenv("repoID");
	console.log("🪚 repoID:", repoID);

	// GET PLUGIN ISSUES
	// GitHub API only returns 100 results https://stackoverflow.com/questions/30656761/github-search-api-only-return-30-results
	const issueAPIURL = `https://api.github.com/repos/${repoID}/issues?state=all&per_page=100`;
	const issueJSON = JSON.parse(app.doShellScript(`curl -s "${issueAPIURL}"`))
		.sort((/** @type {GithubIssue} */ x, /** @type {GithubIssue} */ y) => {
			const a = x.state;
			const b = y.state;
			return a === b ? 0 : a < b ? 1 : -1; 
		})
		.map((/** @type {GithubIssue} */ issue) => {
			const title = issue.title;
			const issueCreator = issue.user.login;

			let state = "";
			if (issue.state === "open") state += "🟢 ";
			else state += "🟣 ";
			if (title.toLowerCase().includes("request") || title.includes("FR")) state += "🙏 ";
			if (title.toLowerCase().includes("suggestion")) state += "💡 ";
			if (title.toLowerCase().includes("bug")) state += "🪲 ";
			if (title.includes("?")) state += "❓ ";
			let comments = "";
			if (issue.comments !== "0") comments = "   💬 " + issue.comments;

			const issueMatcher = [
				issue.state,
				alfredMatcher(title),
				alfredMatcher(issueCreator),
				"#" + issue.number,
			].join(" ");

			return {
				title: state + title,
				match: issueMatcher,
				subtitle: "#" + issue.number + " by " + issueCreator + comments,
				arg: issue.html_url,
			};
		});

	return JSON.stringify({ items: issueJSON });
}
