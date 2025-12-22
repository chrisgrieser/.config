#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_.]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
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
function run() {
	const username = $.getenv("github_username");
	const cloneDepth = Number.parseInt($.getenv("clone_depth"));
	const forkOnClone = $.getenv("fork_on_clone") === "1";

	// DOCS https://docs.github.com/en/rest/activity/starring?apiVersion=2022-11-28#list-repositories-starred-by-the-authenticated-user
	// CAVEAT API does not allow combining the starred repo search with a query,
	// so we have to fetch them all and filter locally ourselves (via Alfred)
	const apiUrl = `https://api.github.com/users/${username}/starred?per_page=100`;

	// Paginate through all repos
	/** @type {GithubRepo[]} */
	const allRepos = [];
	let page = 1;
	while (true) {
		const response = httpRequest(apiUrl + `&page=${page}`);
		if (!response) {
			const item = { title: "No response from GitHub. Try again later.", valid: false };
			return JSON.stringify({ items: [item] });
		}
		const reposOfPage = JSON.parse(response);
		console.log(`repos page #${page}: ${reposOfPage.length}`);
		allRepos.push(...reposOfPage);
		page++;
		if (reposOfPage.length < 100) break; // GitHub returns less than 100 when on last page
	}

	/** @type {AlfredItem[]} */
	const items = allRepos.map((repo) => {
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

		let cloneSubtitle = cloneDepth > 0 ? `⌃: Shallow Clone (depth ${cloneDepth})` : "⌃: Clone";
		if (forkOnClone) cloneSubtitle += " & Fork";

		const secondUrl = repo.homepage || repo.html_url + "/releases";

		return {
			title: type + repo.name,
			subtitle: subtitle,
			arg: repo.html_url,
			match: alfredMatcher(repo.name),
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

	return JSON.stringify({ items: items });
}
