#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/**
 * @param {string} url
 * @param {string[]} header
 * @return {string} response
 */
function httpRequestWithHeaders(url, header) {
	let allHeaders = "";
	for (const line of header) {
		allHeaders += ` -H "${line}"`;
	}
	const curlRequest = `curl --silent --location ${allHeaders} "${url}" || true`;
	console.log("curl command:", curlRequest);
	return app.doShellScript(curlRequest);
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

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// get GITHUB_TOKEN
	const tokenShellCmd = $.getenv("github_token_shell_cmd").trim();
	const tokenFromZshenvCmd = "test -e $HOME/.zshenv && source $HOME/.zshenv ; echo $GITHUB_TOKEN";
	let githubToken = $.getenv("github_token_from_alfred_prefs").trim();
	if (!githubToken && tokenShellCmd) githubToken = app.doShellScript(tokenShellCmd).trim();
	if (!githubToken) githubToken = app.doShellScript(tokenFromZshenvCmd);

	const showReadNotifs =
		$.NSProcessInfo.processInfo.environment.objectForKey("mode").js === "show-read-notifications";

	// GUARD
	if (!githubToken) {
		return JSON.stringify({ items: [{ title: "⚠️ No $GITHUB_TOKEN found.", valid: false }] });
	}

	// CALL GITHUB API
	// DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#list-notifications-for-the-authenticated-user
	const apiUrl = "https://api.github.com/notifications?all=" + showReadNotifs.toString();
	const headers = [
		"Accept: application/vnd.github.json",
		"X-GitHub-Api-Version: 2022-11-28",
		`Authorization: BEARER ${githubToken}`,
	];
	const response = httpRequestWithHeaders(apiUrl, headers);
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
			ctrl: { valid: false, subtitle: "" },
		};
		return JSON.stringify({
			items: [
				{
					title: "Show read notifications",
					variables: { mode: "show-read-notifications" },
					mods: deactivatedMods,
				},
			],
		});
	}

	//───────────────────────────────────────────────────────────────────────────

	/** @type {Record<string, string>} */
	// biome-ignore-start lint/style/useNamingConvention: not by me
	const typeMaps = {
		PullRequest: "🟧",
		Issue: "🔵",
		Discussion: "🗣️",
		CheckSuite: "🤖",
		Release: "🎉",
	};
	/** @type {Record<string, string>} */
	const reasonMaps = {
		author: "👤",
		mention: "⭕",
		team_mention: "⭕",
		subscribed: "🔔",
		comment: "💬",
		assign: "➡",
		ci_activity: "⚙️",
		invitation: "👥",
		manual: "🫱",
		review_requested: "➡",
		security_alert: "❗",
		state_change: "❇️",
	};
	// biome-ignore-end lint/style/useNamingConvention: not by me

	/** @type AlfredItem[] */
	const notifications = responseObj.map((/** @type {GithubNotif} */ notif) => {
		const notifApiUrl = notif.subject.latest_comment_url || notif.subject.url || "";
		const typeIcon = typeMaps[notif.subject.type] || notif.subject.type;
		const reasonIcon = reasonMaps[notif.reason] || notif.reason;
		const updatedAt = humanRelativeDate(notif.updated_at);
		const subtitle = `${typeIcon} ${reasonIcon}  ${notif.repository.name}  ·  ${updatedAt}`;

		/** @type {AlfredItem} */
		const alfredItem = {
			title: notif.subject.title,
			subtitle: subtitle,
			arg: notifApiUrl,
			variables: { mode: "open" },
			mods: {
				cmd: {
					arg: notif.id,
					valid: !showReadNotifs,
					subtitle: showReadNotifs ? "🚫 Is already marked as read." : "⌘: Mark as Read",
					// CAVEAT mark-as-unread not support in GitHub Notification API
					variables: { mode: "mark-as-read", notificationsLeft: responseObj.length - 1 },
				},
				ctrl: {
					arg: notif.id,
					subtitle: "⌃: Mark as done",
					variables: { mode: "mark-as-read", notificationsLeft: responseObj.length - 1 },
				},
				alt: {
					subtitle: notifApiUrl ? "⌥: Copy URL" : "(🚫 No URL)",
					valid: Boolean(notifApiUrl),
					variables: { mode: "copy" },
				},
			},
		};
		return alfredItem;
	});

	return JSON.stringify({ items: notifications });
}
