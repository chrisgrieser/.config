#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
}

/** @param {string} isoDateStr */
function humanRelativeDate(isoDateStr) {
	const deltaMins = (Date.now() - new Date(isoDateStr).getTime()) / 1000 / 60;
	/** @type {"year"|"month"|"week"|"day"|"hour"|"minute"} */
	let unit;
	let delta;
	if (deltaMins < 60) {
		unit = "minute";
		delta = Math.floor(deltaMins);
	} else if (deltaMins < 60 * 24) {
		unit = "hour";
		delta = Math.floor(deltaMins / 60);
	} else if (deltaMins < 60 * 24 * 7) {
		unit = "day";
		delta = Math.floor(deltaMins / 60 / 24);
	} else if (deltaMins < 60 * 24 * 7 * 4) {
		unit = "week";
		delta = Math.floor(deltaMins / 60 / 24 / 7);
	} else if (deltaMins < 60 * 24 * 7 * 4 * 12) {
		unit = "month";
		delta = Math.floor(deltaMins / 60 / 24 / 7 / 4);
	} else {
		unit = "year";
		delta = Math.floor(deltaMins / 60 / 24 / 7 / 4 / 12);
	}
	const formatter = new Intl.RelativeTimeFormat("en", { style: "narrow", numeric: "auto" });
	const str = formatter.format(-delta, unit);
	return str.replace(/m(?= ago$)/, "min"); // "m" -> "min" (more distinguishable from "month")
}

/** @param {number} starcount */
function shortNumber(starcount) {
	const starStr = starcount.toString();
	if (starcount < 2000) return starStr;
	return starStr.slice(0, -3) + "k";
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
	const apiUrl = "https://api.github.com/search/repositories?q=" + encodeURIComponent(query);
	const response = httpRequest(apiUrl);
	if (!response) {
		return JSON.stringify({
			items: [{ title: "No response from GitHub.", subtitle: "Try again later.", valid: false }],
		});
	}

	//───────────────────────────────────────────────────────────────────────────

	const forkOnClone = $.getenv("fork_on_clone") === "1";
	const cloneDepth = Number.parseInt($.getenv("clone_depth"));
	const shallowClone = cloneDepth > 0;

	/** @type {AlfredItem[]} */
	const repos = JSON.parse(response).items.map((/** @type {GithubRepo} */ repo) => {
		// INFO `pushed_at` refers to commits only https://github.com/orgs/community/discussions/24442
		// CAVEAT `pushed_at` apparently also includes pushes via PR :(
		const lastUpdated = repo.pushed_at ? humanRelativeDate(repo.pushed_at) : "";

		let type = "";
		if (repo.fork) type += "🍴 ";
		if (repo.archived) type += "🗄️ ";

		const subtitle = [
			repo.owner.login,
			"★ " + shortNumber(repo.stargazers_count),
			lastUpdated,
			repo.description,
		]
			.filter(Boolean)
			.join("  ·  ");

		let cloneSubtitle = shallowClone ? `⌃: Shallow Clone (depth ${cloneDepth})` : "⌃: Clone";
		if (forkOnClone) cloneSubtitle += " & Fork";

		const secondUrl = repo.homepage || repo.html_url + "/releases";

		return {
			title: type + repo.name,
			subtitle: subtitle,
			arg: repo.html_url,
			// no `match:`, since not using Alfred for filtering results
			quicklookurl: repo.html_url,
			mods: {
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
