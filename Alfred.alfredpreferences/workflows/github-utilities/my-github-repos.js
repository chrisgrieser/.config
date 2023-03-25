#!/usr/bin/env osascript -l JavaScript
function run() {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function alfredMatcher(str) {
		const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
		const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
		return [clean, camelCaseSeperated, str].join(" ") + " ";
	}

	//──────────────────────────────────────────────────────────────────────────────

	const username = $.getenv("github_username");
	const apiURL = `https://api.github.com/users/${username}/repos?per_page=100`;

	const jsonArray = JSON.parse(app.doShellScript(`curl -sL "${apiURL}"`))
		.sort((a, b) => {
			// sort archived and forks to the bottom, then sort by stars
			if (a.fork && !b.fork) return 1;
			else if (!a.fork && b.fork) return -1;
			else if (a.archived && !b.archived) return 1;
			else if (!a.archived && b.archived) return -1;
			return b.stargazers_count - a.stargazers_count
		})
		.map(item => {
			let repo = item.full_name.split("/")[1];
			if (repo === username) repo = "My GitHub Profile";
			const url = item.html_url;
			const stars = item.stargazers_count;
			const issues = item.open_issues_count;
			const forks = item.forks_count;

			let matcher = alfredMatcher(repo);

			let info = "";
			if (item.archived) {
				info += "🗄️ ";
				matcher += "archived "
			}
			if (item.fork) {
				info += "🍽️ ";
				matcher += "fork "
			}
			if (stars > 0) info += `⭐ ${stars}  `;
			if (issues > 0) info += `🟢 ${issues}  `;
			if (forks > 0) info += `🍴 ${forks}  `;

			return {
				title: repo,
				subtitle: info,
				match: matcher,
				arg: url,
			};
		});
	return JSON.stringify({ items: jsonArray });
}
