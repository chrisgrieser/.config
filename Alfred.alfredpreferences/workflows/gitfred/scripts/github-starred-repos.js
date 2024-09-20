#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	const requestStr = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
	return requestStr;
}

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_.]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
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
function run() {
	const username = $.getenv("github_username");
	const forkOnClone = $.getenv("fork_on_clone") === "1";
	const cloneDepth = Number.parseInt($.getenv("clone_depth"));
	const shallowClone = cloneDepth > 0;

	// DOCS https://docs.github.com/en/rest/activity/starring?apiVersion=2022-11-28#list-repositories-starred-by-a-user
	const apiURL = `https://api.github.com/users/${username}/starred?per_page=100`;
	const response = httpRequest(apiURL);
	if (!response) {
		return JSON.stringify({
			items: [{ title: "No response from GitHub.", subtitle: "Try again later.", valid: false }],
		});
	}

	/** @type AlfredItem[] */
	const repos = JSON.parse(response).map((/** @type {GithubRepo} */ repo) => {
		const lastUpdated = repo.pushed_at ? humanRelativeDate(repo.pushed_at) : "";

		const components = [
			repo.owner.login,
			"★ " + repo.stargazers_count,
			lastUpdated,
			repo.description,
		];
		const subtitle = components.filter(Boolean).join("  ·  ");

		let cloneSubtitle = shallowClone ? `⌃: Shallow Clone (depth ${cloneDepth})` : "⌃: Clone";
		if (forkOnClone) cloneSubtitle += " & Fork";
		const secondUrl = repo.homepage || repo.html_url + "/releases";

		return {
			title: repo.name,
			subtitle: subtitle,
			match: alfredMatcher(repo.name),
			arg: repo.html_url,
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

	return JSON.stringify({
		items: repos,
		cache: { seconds: 1800 },
	});
}
