#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_.]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestStr = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestStr;
}

/**
 * @param {string} isoDateStr string to be converted to a date
 * @return {string} relative date
 */
function humanRelativeDate(isoDateStr) {
	const deltaSecs = (+new Date() - +new Date(isoDateStr)) / 1000;
	/** @type {"year"|"month"|"week"|"day"|"hour"|"minute"|"second"} */
	let unit;
	let delta;
	if (deltaSecs < 60) {
		unit = "second";
		delta = Math.ceil(deltaSecs);
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
	const formatter = new Intl.RelativeTimeFormat("en", { style: "narrow", numeric: "auto" });
	const str = formatter.format(-delta, unit);
	return str.replace(/m(?= ago$)/, "min"); // "m" -> "min" (more distinguishable from "month")
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const query = argv[0];

	// GUARD
	if (!query) {
		return JSON.stringify({ items: [{ title: "Waiting for query…", valid: false }] });
	}

	// DOCS https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28#search-repositories
	const apiURL = `https://api.github.com/search/repositories?q=${encodeURIComponent(query)}`;
	const response = JSON.parse(httpRequest(apiURL));

	const forkOnClone = $.getenv("fork_on_clone") === "1";
	const depthInfo = $.getenv("clone_depth") ? ` (depth ${$.getenv("clone_depth")})` : "";

	/** @type {AlfredItem[]} */
	const repos = response.items
		.filter((/** @type {GithubRepo} */ repo) => !(repo.fork || repo.archived))
		.map((/** @type {GithubRepo} */ repo) => {
			// calculate relative date
			// INFO pushed_at refers to commits only https://github.com/orgs/community/discussions/24442
			// CAVEAT pushed_at apparently also includes pushes via PR :(
			const lastUpdated = repo.pushed_at ? humanRelativeDate(repo.pushed_at) : "";

			const subtitle = [
				repo.owner.login,
				"★ " + repo.stargazers_count,
				lastUpdated,
				repo.description,
			]
				.filter(Boolean)
				.join("  ·  ");

			const cloneSubtitle = "⌃: Shallow Clone " + depthInfo + (forkOnClone ? " & Fork" : "");
			const secondUrl = repo.homepage || repo.html_url + "/releases";

			return {
				title: repo.name,
				subtitle: subtitle,
				match: alfredMatcher(repo.name),
				arg: repo.html_url,
				quicklookurl: repo.html_url,
				mods: {
					shift: {
						subtitle: `⇧: Search Issues (${repo.open_issues} open)`,
						arg: repo.full_name,
					},
					cmd: {
						arg: secondUrl,
						subtitle: `⌘: Open  "${secondUrl}"`,
					},
					ctrl: {
						subtitle: cloneSubtitle,
					},
				},
			};
		});

	// GUARD no results
	if (repos.length === 0) {
		repos.push({
			title: "🚫 No results",
			subtitle: `No results found for '${query}'`,
			valid: false,
			mods: {
				shift: { valid: false },
				cmd: { valid: false },
				alt: { valid: false },
				ctrl: { valid: false },
			},
		});
	}
	return JSON.stringify({ items: repos });
}
