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

/**
 * @param {string} url
 * @param {string[]} header
 * @return {string} response
 */
function httpRequestWithHeaders(url, header) {
	let allHeaders = "";
	for (const line of header) {
		allHeaders += ` -H "${line}"`;
	}
	const curlRequest = `curl --silent --location ${allHeaders} "${url}" || true`;
	console.log("curl command:", curlRequest);
	return app.doShellScript(curlRequest);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: alfred_run
function run() {
	// get GITHUB_TOKEN
	const tokenShellCmd = $.getenv("github_token_shell_cmd").trim();
	const tokenFromZshenvCmd = "test -e $HOME/.zshenv && source $HOME/.zshenv ; echo $GITHUB_TOKEN";
	let githubToken = $.getenv("github_token_from_alfred_prefs").trim();
	if (!githubToken && tokenShellCmd) githubToken = app.doShellScript(tokenShellCmd).trim();
	if (!githubToken) githubToken = app.doShellScript(tokenFromZshenvCmd);

	const username = $.getenv("github_username");

	// DOCS https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#list-issues-assigned-to-the-authenticated-user--parameters
	const apiUrl = `https://api.github.com/search/issues?q=involves:${username}&sort=updated&per_page=100`;
	const headers = ["Accept: application/vnd.github.json", "X-GitHub-Api-Version: 2022-11-28"];
	if (githubToken) headers.push(`Authorization: BEARER ${githubToken}`);

	const response = httpRequestWithHeaders(apiUrl, headers);
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
