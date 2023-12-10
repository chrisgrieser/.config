#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/**
 * @param {string} url
 * @param {string[]} header
 * @param {string=} extraOpts
 * @return {string} response
 */
function httpRequestWithHeaders(url, header, extraOpts) {
	let allHeaders = "";
	for (const line of header) {
		allHeaders += `-H "${line}" `;
	}
	extraOpts = extraOpts || "";
	const curlRequest = `curl -L ${allHeaders} "${url}" ${extraOpts}`;
	const response = app.doShellScript(curlRequest);
	return response;
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
	return formatter.format(-delta, unit);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const githubToken = argv[0];
	if (!githubToken) {
		return JSON.stringify({
			items: [
				{
					title: "⚠️ No $GITHUB_TOKEN found.",
					subtitle: "Please export it in your `.zshenv`.",
					valid: false,
				},
			],
		});
	}

	// DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#list-notifications-for-the-authenticated-user
	const response = httpRequestWithHeaders("https://api.github.com/notifications", [
		"Accept: application/vnd.github.v3+json",
		`Authorization: BEARER ${githubToken}`,
		"X-GitHub-Api-Version: 2022-11-28",
	]);
	const responseObj = JSON.parse(response);
	if (responseObj.length === 0) {
		return JSON.stringify({
			items: [
				{
					title: "Open Notification Inbox at Github.",
					arg: "https://github.com/notifications?query=is%3Aunread",
					variables: { mode: "direct-open" },
					mods: { cmd: { valid: false }, alt: { valid: false } },
				},
				{
					title: "Show Read Notifications",
					arg: "https://github.com/notifications?query=is%3Aunread",
					mods: { cmd: { valid: false }, alt: { valid: false } },
				},
			],
		});
	}

	const typeMaps = {
		// biome-ignore lint/style/useNamingConvention: not by me
		PullRequest: "🟧", //codespell-ignore
		// biome-ignore lint/style/useNamingConvention: not by me
		Issue: "🔵",
		// biome-ignore lint/style/useNamingConvention: not by me
		Discussion: "🏛️",
		// biome-ignore lint/style/useNamingConvention: not by me
		CheckSuite: "🤖",
		// biome-ignore lint/style/useNamingConvention: not by me
		Release: "🎉",
	};
	const reasonMaps = {
		author: "👤",
		mention: "⭕",
		// biome-ignore lint/style/useNamingConvention: not by me
		team_mention: "⭕",
		subscribed: "🔔",
		comment: "💬",
		assign: "➡️",
		// biome-ignore lint/style/useNamingConvention: not by me
		ci_activity: " ",
		invitation: "👥",
		manual: "Ⓜ️",
		// biome-ignore lint/style/useNamingConvention: not by me
		review_requested: "➡️",
		// biome-ignore lint/style/useNamingConvention: not by me
		security_alert: "❗",
		// biome-ignore lint/style/useNamingConvention: not by me
		state_change: "✴️",
	};

	/** @type AlfredItem[] */
	const notifications = responseObj.map((/** @type {GithubNotif} */ notif) => {
		const apiUrl = notif.subject.latest_comment_url || notif.subject.url || "";
		const typeIcon = typeMaps[notif.subject.type] || notif.subject.type;
		const reasonIcon = reasonMaps[notif.reason] || notif.reason;
		const updatedAt = relativeDate(notif.updated_at);
		const subtitle = `${typeIcon} ${reasonIcon}  ${notif.repository.name}  ·  ${updatedAt}`;

		return {
			title: notif.subject.title,
			subtitle: subtitle,
			arg: apiUrl,
			variables: { mode: "open" },
			mods: {
				cmd: {
					arg: notif.id,
					variable: {
						notificationsLeft: responseObj.length - 1,
						mode: "mark-as-read",
					},
				},
				alt: {
					variable: {
						mode: "copy",
						valid: Boolean(apiUrl),
						subtitle: apiUrl ? "" : "(🚫 No URL)",
					},
				},
			},
		};
	});

	return JSON.stringify({ items: notifications });
}
