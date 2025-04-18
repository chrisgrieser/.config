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
	return app.doShellScript(curlRequest);
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

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const tokenShellCmd = "test -e $HOME/.zshenv && source $HOME/.zshenv ; echo $GITHUB_TOKEN";
	const githubToken =
		$.getenv("github_token_from_alfred_prefs").trim() || app.doShellScript(tokenShellCmd).trim();
	const showReadNotifs =
		$.NSProcessInfo.processInfo.environment.objectForKey("mode").js === "show-read-notifications";

	// GUARD
	if (!githubToken) {
		return JSON.stringify({
			items: [
				{
					title: "⚠️ No $GITHUB_TOKEN found.",
					subtitle: "Neither the Workflow Configuration nor the `.zshenv` have a token.",
					valid: false,
				},
			],
		});
	}

	// CALL GITHUB API
	// DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#list-notifications-for-the-authenticated-user
	const parameter = showReadNotifs ? "?all=true" : "";
	const response = httpRequestWithHeaders("https://api.github.com/notifications" + parameter, [
		"Accept: application/vnd.github.v3+json",
		`Authorization: BEARER ${githubToken}`,
		"X-GitHub-Api-Version: 2022-11-28",
	]);
	if (!response) {
		return JSON.stringify({
			items: [{ title: "No response from GitHub.", subtitle: "Try again later.", valid: false }],
		});
	}
	const responseObj = JSON.parse(response);

	// GUARD error, for example invalid API token
	if (responseObj.message) {
		return JSON.stringify({
			items: [{ title: responseObj.message, subtitle: "Error", valid: false }],
		});
	}

	// GUARD: no notifications
	if (responseObj.length === 0) {
		const deactivatedMods = {
			cmd: { valid: false, subtitle: "" },
			alt: { valid: false, subtitle: "" },
		};
		return JSON.stringify({
			items: [
				{
					title: "Show Read Notifications",
					variables: { mode: "show-read-notifications" },
					mods: deactivatedMods,
				},
				{
					title: "Open Notification Inbox",
					variables: { mode: "open-inbox" },
					mods: deactivatedMods,
				},
			],
		});
	}

	//───────────────────────────────────────────────────────────────────────────

	/** @type {Record<string, string>} */
	const typeMaps = {
		// biome-ignore lint/style/useNamingConvention: not by me
		PullRequest: "🟧",
		// biome-ignore lint/style/useNamingConvention: not by me
		Issue: "🔵",
		// biome-ignore lint/style/useNamingConvention: not by me
		Discussion: "🗣️",
		// biome-ignore lint/style/useNamingConvention: not by me
		CheckSuite: "🤖",
		// biome-ignore lint/style/useNamingConvention: not by me
		Release: "🎉",
	};
	/** @type {Record<string, string>} */
	const reasonMaps = {
		author: "👤",
		mention: "⭕",
		// biome-ignore lint/style/useNamingConvention: not by me
		team_mention: "⭕",
		subscribed: "🔔",
		comment: "💬",
		assign: "➡",
		// biome-ignore lint/style/useNamingConvention: not by me
		ci_activity: "⚙️",
		invitation: "👥",
		manual: "🫱",
		// biome-ignore lint/style/useNamingConvention: not by me
		review_requested: "➡",
		// biome-ignore lint/style/useNamingConvention: not by me
		security_alert: "❗",
		// biome-ignore lint/style/useNamingConvention: not by me
		state_change: "❇️",
	};

	/** @type AlfredItem[] */
	const notifications = responseObj.map((/** @type {GithubNotif} */ notif) => {
		const apiUrl = notif.subject.latest_comment_url || notif.subject.url || "";
		const typeIcon = typeMaps[notif.subject.type] || notif.subject.type;
		const reasonIcon = reasonMaps[notif.reason] || notif.reason;
		const updatedAt = humanRelativeDate(notif.updated_at);
		const subtitle = `${typeIcon} ${reasonIcon}  ${notif.repository.name}  ·  ${updatedAt}`;

		/** @type {AlfredItem} */
		const alfredItem = {
			title: notif.subject.title,
			subtitle: subtitle,
			arg: apiUrl,
			variables: { mode: "open" },
			mods: {
				cmd: {
					arg: notif.id,
					// CAVEAT mark-as-unread not support in GitHub Notification API
					valid: !showReadNotifs,
					subtitle: showReadNotifs ? "🚫 Is already marked as read." : "⌘: Mark as Read",
					variables: { mode: "mark-as-read", notificationsLeft: responseObj.length - 1 },
				},
				alt: {
					subtitle: apiUrl ? "⌥: Copy URL" : "(🚫 No URL)",
					valid: Boolean(apiUrl),
					variables: { mode: "copy" },
				},
			},
		};
		return alfredItem;
	});

	return JSON.stringify({ items: notifications });
}
