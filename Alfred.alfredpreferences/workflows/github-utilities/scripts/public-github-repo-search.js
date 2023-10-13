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

	/** @type {AlfredItem[]} */
	const repos = JSON.parse(httpRequest(apiURL))
		.items.filter((/** @type {GithubRepo} */ repo) => !(repo.fork || repo.archived))
		.map((/** @type {GithubRepo} */ repo) => {

			// calculate relative date
			// INFO pushed_at refers to commits only https://github.com/orgs/community/discussions/24442
			// CAVEAT pushed_at apparently also includes pushes via PR :(
			const daysAgo = Math.ceil((+new Date() - +new Date(repo.pushed_at)) / 1000 / 3600 / 24);
			let updated =
				daysAgo < 31
					? daysAgo.toString() + " days ago"
					: Math.ceil(daysAgo / 30).toString() + " months ago";
			if (updated.startsWith("1 ")) updated = updated.replace("s ago", " ago");

			const subtitle = [
				repo.owner.login,
				"★ " + repo.stargazers_count,
				updated,
				repo.description
			].join("  ·  ");

			return {
				title: repo.name,
				subtitle: subtitle,
				match: alfredMatcher(repo.name),
				arg: repo.html_url,
				mods: {
					shift: {
						subtitle: `⇧: Search Issues (${repo.open_issues} open)`,
						arg: repo.full_name,
					},
				},
			};
		});

	if (repos.length === 0) {
		repos.push({
			title: "🚫 No results",
			subtitle: `No results found for '${query}'`,
			valid: false,
		});
	}
	return JSON.stringify({ items: repos });
}
