#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryURL);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/**
 * @param {string} isoDateStr string to be converted to a date
 * @return {string} relative date
 */
function humanRelativeDate(isoDateStr) {
	const deltaMins = (Date.now() - +new Date(isoDateStr)) / 1000 / 60;
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

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: alfred_run
function run() {
	const username = $.getenv("github_username");
	const apiURL = `https://api.github.com/search/issues?q=author:${username}+is:pr+is:open&per_page=100`;
	const response = httpRequest(apiURL);
	if (!response) {
		return JSON.stringify({
			items: [{ title: "No response from GitHub.", subtitle: "Try again later.", valid: false }],
		});
	}

	const openPrs = JSON.parse(response).items.map((/** @type {GithubIssue} */ item) => {
		const repo = (item.repository_url.match(/[^/]+$/) || "")[0];
		const comments = item.comments > 0 ? "💬 " + item.comments.toString() : "";
		const icon = item.draft ? "⬜" : "🟩 ";

		const components = [
			`#${item.number}`,
			repo,
			comments.toString(),
			`(${humanRelativeDate(item.created_at)})`,
		];
		const subtitle = components.filter(Boolean).join("   ");

		return {
			title: icon + item.title,
			subtitle: subtitle,
			match: alfredMatcher(item.title) + alfredMatcher(repo),
			arg: item.html_url,
			quicklookurl: item.html_url,
		};
	});
	return JSON.stringify({
		items: openPrs,
		cache: {
			seconds: 150, // fast to pick up recently created prs
			loosereload: true,
		},
	});
}
