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
		.map(repo => {
			let name = repo.full_name.split("/")[1];
			if (name === username) name = "My GitHub Profile";
			
			let matcher = alfredMatcher(name);
			let subtitle = "";
			if (repo.archived) {
				subtitle += "🗄️ ";
				matcher += "archived "
			}
			if (repo.fork) {
				subtitle += "🍽️ ";
				matcher += "fork "
			}
			if (repo.stargazers_count > 0) subtitle += `⭐ ${repo.stargazers_count}  `;
			if (repo.open_issues_count > 0) subtitle += `🟢 ${repo.open_issues_count}  `;
			if (repo.forks_count > 0) subtitle += `🍴 ${repo.forks_count}  `;

			return {
				title: name,
				subtitle: subtitle,
				match: matcher,
				arg: repo.html_url,
				mods: {
					shift: {
						subtitle: `⇧: Search Issues (${repo.open_issues} open)`,
						arg: repo.full_name,
					},
				},
			};
		});
	return JSON.stringify({ items: jsonArray });
}
