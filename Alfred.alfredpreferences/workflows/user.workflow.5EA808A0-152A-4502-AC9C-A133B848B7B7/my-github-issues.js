#!/usr/bin/env osascript -l JavaScript
/* eslint-disable complexity */
function run() {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function alfredMatcher(str) {
		const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
		const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
		return [clean, camelCaseSeperated, str].join(" ");
	}

	//──────────────────────────────────────────────────────────────────────────────

	const resultsNumber = $.getenv("results_number");
	const username = $.getenv("github_username");
	const apiURL = `https://api.github.com/search/issues?q=involves:${username}&per_page=${resultsNumber}`;

	const issues = JSON.parse(app.doShellScript(`curl -sL "${apiURL}"`)).items.map(item => {
		const isPR = Boolean(item.pull_request);
		const merged = Boolean(item.pull_request?.merged_at);
		const title = item.title;
		const repo = item.repository_url.match(/[^/]+\/[^/]+$/)[0];
		const comments = item.comments > 0 ? "💬 " + item.comments.toString() : "";

		let icon; // also lists PRs due to --include-prs
		if (item.state === "open" && isPR) icon = "🟦 ";
		else if (item.state === "closed" && isPR && merged) icon = "🟨 ";
		else if (item.state === "closed" && isPR && !merged) icon = "🟥 ";
		else if (item.state === "closed" && !isPR) icon = "🟣 ";
		else if (item.state === "open" && !isPR) icon = "🟢 ";
		if (title.toLowerCase().includes("request") || title.includes("FR")) icon += "🙏 ";
		if (title.toLowerCase().includes("bug")) icon += "🪲 ";

		let matcher = alfredMatcher(item.title) + " " + alfredMatcher(repo);
		if (isPR) matcher += " pr";

		return {
			title: icon + title,
			subtitle: `#${item.number}  ${repo}   ${comments}`,
			match: matcher,
			arg: item.html_url,
		};
	});
	return JSON.stringify({ items: issues });
}
