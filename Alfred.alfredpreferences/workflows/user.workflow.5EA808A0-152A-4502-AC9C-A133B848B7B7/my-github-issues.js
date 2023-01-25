#!/usr/bin/env osascript -l JavaScript
function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function alfredMatcher(str) {
		const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
		const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
		return [clean, camelCaseSeperated, str].join(" ");
	}

	//──────────────────────────────────────────────────────────────────────────────

	const token = argv[0];
	const username = $.getenv("github_username");
	const issues = JSON.parse(
		app.doShellScript(
			`echo "${token}" | gh auth login --with-token ; gh search issues --include-prs --involves=${username} --json="repository,title,url,number,state,commentsCount"`,
		),
	// eslint-disable-next-line complexity
	).map(item => {
		const isPR = item.url.includes("pull");
		
		const title = item.title;

		let icon; // also lists PRs due to --include-prs
		if (item.state === "merged") icon = "🟦 ";
		else if (item.state === "closed" && isPR) icon = "🟥 ";
		else if (item.state === "open" && isPR) icon = "🟨 ";
		else if (item.state === "closed" && !isPR) icon = "🟣 ";
		else if (item.state === "open" && !isPR) icon = "🟢 ";

		if (title.toLowerCase().includes("request") || title.includes("FR")) icon += "🙏 ";
		if (title.toLowerCase().includes("suggestion")) icon += "💡 ";
		if (title.toLowerCase().includes("bug")) icon += "🪲 ";
		if (title.includes("?")) icon += "❓ ";

		const repo = item.repository.nameWithOwner;
		const comments = item.commentsCount > 0 ? "💬 " + item.commentsCount.toString() : "";
		let matcher = alfredMatcher(item.title) + " " + alfredMatcher(repo);
		if (isPR) matcher += " pr";

		return {
			title: icon + title,
			subtitle: `#${item.number}  ${repo}   ${comments}`,
			match: matcher,
			arg: item.url,
		};
	});
	return JSON.stringify({ items: issues });
}
