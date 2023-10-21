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

/**
 * @param {string} absoluteDate string to be converted to a date
 * @return {string} relative date
 */
function relativeDate(absoluteDate) {
	const deltaSecs = (+new Date() - +new Date(absoluteDate)) / 1000;
	/** @type {"year"|"month"|"week"|"day"|"hour"|"minute"|"second"} */
	let unit;
	let delta;
	if (deltaSecs < 60) {
		unit = "second";
		delta = deltaSecs;
	} else if (deltaSecs < 60 * 60) {
		unit = "minute";
		delta = Math.ceil(deltaSecs / 60);
	} else if (deltaSecs < 60 * 60 * 24) {
		unit = "hour";
		delta = Math.ceil(deltaSecs / 60 / 60);
	} else if (deltaSecs < 60 * 60 * 24 * 7) {
		unit = "day";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24);
	} else if (deltaSecs < 60 * 60 * 24 * 7 * 4) {
		unit = "week";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24 / 7);
	} else if (deltaSecs < 60 * 60 * 24 * 7 * 4 * 12) {
		unit = "month";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24 / 7 / 4);
	} else {
		unit = "year";
		delta = Math.ceil(deltaSecs / 60 / 60 / 24 / 7 / 4 / 12);
	} 
	const formatter = new Intl.RelativeTimeFormat("en", { style: "long", numeric: "auto" });
	return formatter.format(-delta, unit);
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
			console.log("🪚 " + repo.full_name);

			// calculate relative date
			// INFO pushed_at refers to commits only https://github.com/orgs/community/discussions/24442
			// CAVEAT pushed_at apparently also includes pushes via PR :(
			const lastUpdated = repo.pushed_at ? relativeDate(repo.pushed_at) : "";

			const subtitle = [
				repo.owner.login,
				"★ " + repo.stargazers_count,
				lastUpdated,
				repo.description,
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
	return JSON.stringify({
		items: repos,
		variables: { publicRepo: "true" },
	});
}
