#!/usr/bin/env osascript -l JavaScript

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	return [clean, str].join(" ") + " ";
}

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0] || "";
	if (!query) return;
	const apiURL = `https://api.github.com/search/repositories?q=${encodeURIComponent(query)}`;

	const jsonArray = JSON.parse(httpRequest(apiURL))
		.items.filter((/** @type {{ fork: boolean; archived: boolean; }} */ repo) => !(repo.fork || repo.archived))
		.map((/** @type {{ full_name: string; updated_at: string | number | Date; stargazers_count: any; description: string; html_url: any; open_issues: any; }} */ repo) => {
			const name = repo.full_name.split("/")[1];

			// calculate relative date
			const daysAgo = Math.ceil((+new Date() - +new Date(repo.updated_at)) / 1000 / 3600 / 24);
			let updated =
				daysAgo < 31 ? daysAgo.toString() + " days ago" : Math.ceil(daysAgo / 30).toString() + " months ago";
			if (updated.startsWith("1 ")) updated = updated.replace("s ago", " ago");

			let subtitle = `★ ${repo.stargazers_count} – ${updated}`;
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
