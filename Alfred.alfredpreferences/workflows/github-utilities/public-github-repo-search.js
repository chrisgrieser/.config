#!/usr/bin/env osascript -l JavaScript
/* eslint-disable no-magic-numbers */
function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function alfredMatcher(str) {
		const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
		return [clean, str].join(" ") + " ";
	}

	//──────────────────────────────────────────────────────────────────────────────

	const query = argv[0];
	if (query.match(/^\s*$/)) return; // don't run for empty query
	const apiURL = `https://api.github.com/search/repositories?q=${query}`;

	const jsonArray = JSON.parse(app.doShellScript(`curl -sL "${apiURL}"`))
		.items.filter(repo => !repo.fork && !repo.archived)
		.map(repo => {
			const name = repo.full_name.split("/")[1];

			const daysAgo = Math.ceil((new Date() - new Date(repo.updated_at)) / 1000 / 3600 / 24);
			let updated =
				daysAgo < 31 ? daysAgo.toString() + " days ago" : Math.ceil(daysAgo / 30).toString() + " months ago";
			if (updated.startsWith("1 ")) updated = updated.replace("s ago", " ago"); // remove plural "s"

			let subtitle = `★ ${repo.stargazers_count} – ${updated} – ${repo.description}`;
			if (repo.description) subtitle += " – " + repo.description;

			return {
				title: name,
				subtitle: subtitle,
				match: alfredMatcher(name),
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
