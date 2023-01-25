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
			`echo "${token}" | gh auth login --with-token ; gh search issues --involves=${username} --json="repository,title,url,number,state,commentsCount"`,
		),
	).map(item => {
		const icon = item.state === "open" ? "🟣" : "🟢"
		const repo = item.repository.nameWithOwner
		const comments = item.commentsCount > 0 ? item.commentsCount.toString() + " "

		if (issue.comments !== "0") comments = "   💬 " + issue.comments;

		return {
			title: `${icon} ${item.title}`,
			subtitle: `#${item.number} ${repo}`,
			match: alfredMatcher(item.title),
			arg: item.url,
		};
	});
	return JSON.stringify({ items: issues });
}
