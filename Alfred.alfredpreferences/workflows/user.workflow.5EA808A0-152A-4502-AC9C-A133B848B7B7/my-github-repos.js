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
	const jsonArray = JSON.parse(app.doShellScript(`curl -sL "https://api.github.com/users/${username}/repos?per_page=100"`))
		.filter(item => item.fork === false)
		.map(item => {
			let repo = item.full_name.split("/")[1];
			if (repo === username) repo = "My GitHub Profile";
			const url = item.html_url;
			const stars = item.stargazers_count;
			const issues = item.open_issues_count;
			const forks = item.fork_count;
			const archived = item.archived ? "[archived]" : "";
			let info = ""
			if (stars > 0) info += `⭑ ${stars}  `
			if (issues > 0) info += `● ${issues}`
			if (forks > 0) info += `⑂ ${forks}`

			return {
				title: `${repo}   ${archived}`,
				subtitle: info,
				match: alfredMatcher(repo),
				arg: url,
				uid: repo,
			};
		});
	return JSON.stringify({ items: jsonArray });
}
