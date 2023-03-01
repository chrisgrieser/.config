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

	const username = $.getenv("github_username");
	const apiURL = `https://api.github.com/users/${username}/repos?per_page=100`;

	const jsonArray = JSON.parse(app.doShellScript(`curl -sL "${apiURL}"`))
		.filter(item => !item.fork)
		.sort((a, b) => {
			// sort archived at the bottom, then sort by stars
			if (a.archived && !b.archived) return 1;
			if (!a.archived && b.archived) return -1;
			return b.stargazers_count - a.stargazers_count
		})
		.map(item => {
			let repo = item.full_name.split("/")[1];
			if (repo === username) repo = "My GitHub Profile";
			const url = item.html_url;
			const stars = item.stargazers_count;
			const issues = item.open_issues_count;
			const forks = item.forks_count;

			let info = "";
			if (item.archived) info += "🗄️ ";
			if (stars > 0) info += `⭐ ${stars}  `;
			if (issues > 0) info += `🟢 ${issues}  `;
			if (forks > 0) info += `🍴 ${forks}  `;

			return {
				title: repo,
				subtitle: info,
				match: alfredMatcher(repo),
				arg: url,
			};
		});
	return JSON.stringify({ items: jsonArray });
}
