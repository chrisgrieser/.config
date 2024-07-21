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

/**
 * @param {string} isoDateStr string to be converted to a date
 * @return {string} relative date
 */
function humanRelativeDate(isoDateStr) {
	const deltaSecs = (Date.now() - +new Date(isoDateStr)) / 1000;
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
	const formatter = new Intl.RelativeTimeFormat("en", { style: "long", numeric: "auto" });
	const str = formatter.format(-delta, unit);
	return str.replace(/m(?= ago$)/, "min"); // "m" -> "min" (more distinguishable from "month")
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: alfred_run
function run() {
	const username = $.getenv("github_username");
	const apiURL = `https://api.github.com/search/issues?q=author:${username}+is:pr+is:open&per_page=100`;

	const openPrs = JSON.parse(app.doShellScript(`curl -sL "${apiURL}"`)).items.map(
		(/** @type {GithubIssue} */ item) => {
			const repo = (item.repository_url.match(/[^/]+$/) || "")[0];
			const comments = item.comments > 0 ? "💬 " + item.comments.toString() : "";
			const icon = item.draft ? "⬜" : "🟩 ";

			const subtitle = [
				`#${item.number}`,
				repo,
				comments.toString(),
				`(${humanRelativeDate(item.created_at)})`,
			]
				.filter(Boolean)
				.join("   ");

			return {
				title: icon + item.title,
				subtitle: subtitle,
				match: alfredMatcher(item.title) + alfredMatcher(repo),
				arg: item.html_url,
				quicklookurl: item.html_url,
			};
		},
	);
	return JSON.stringify({
		items: openPrs,
		cache: {
			seconds: 150, // fast to pick up recently created prs
			loosereload: true,
		},
	});
}
