#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

const isEnterprise = $.getenv("github_enterprise_url").trim() !== "";

/** @param {string} token */
function getApiBaseUrl(token) {
	const enterpriseUrl = $.getenv("github_enterprise_url")?.trim();
	return isEnterprise && token ? `https://${enterpriseUrl}/api/v3` : "https://api.github.com";
}

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
	console.log(curlRequest);
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

function getGithubToken() {
	const tokenShellCmd = $.getenv("github_token_shell_cmd");
	const tokenFromZshenvCmd = "test -e $HOME/.zshenv && source $HOME/.zshenv ; echo $GITHUB_TOKEN";
	let githubToken = $.getenv("github_token_from_alfred_prefs").trim();
	if (!githubToken && tokenShellCmd) {
		githubToken = app.doShellScript(tokenShellCmd + " || true").trim();
		if (!githubToken) console.log("GitHub token shell command failed.");
	}
	if (!githubToken) githubToken = app.doShellScript(tokenFromZshenvCmd);
	return githubToken;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const githubToken = getGithubToken();

	const showReadNotifs =
		$.NSProcessInfo.processInfo.environment.objectForKey("mode").js === "show-read-notifications";

	// GUARD
	if (!githubToken) {
		return JSON.stringify({ items: [{ title: "⚠️ No $GITHUB_TOKEN found.", valid: false }] });
	}

	// CALL GITHUB API
	// DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#list-notifications-for-the-authenticated-user
	const apiUrl = getApiBaseUrl(githubToken) + "/notifications?all=" + showReadNotifs.toString();
	const headers = [
		"Accept: application/vnd.github.json",
		"X-GitHub-Api-Version: 2022-11-28",
		`Authorization: BEARER ${githubToken}`,
	];
	const response = httpRequestWithHeaders(apiUrl, headers);

	// GUARD no response
	if (!response) {
		return JSON.stringify({
			items: [{ title: "No response from GitHub.", subtitle: "Try again later.", valid: false }],
		});
	}
	// GUARD errors like invalid API token or rate limit
	const responseObj = JSON.parse(response);
	if (responseObj.message) {
		const item = { title: "Request denied.", subtitle: responseObj.message, valid: false };
		return JSON.stringify({ items: [item] });
	}

	// GUARD no notifications
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
					variables: { mode: "read", notificationsLeft: responseObj.length - 1 },
				},
				shift: {
					arg: notif.id,
					subtitle: "⇧: Mark as done",
					variables: { mode: "done", notificationsLeft: responseObj.length - 1 },
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
