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
					subtitle: "Please add it to your .zshenv",
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
					title: "No unread notifications.",
					subtitle: "⏎: Open Notification Inbox at Github.",
					arg: "https://github.com/notifications",
					mods: {
						cmd: { valid: false },
					},
				},
			],
		});
	}

	const typeMaps = {
		// biome-ignore lint/style/useNamingConvention: not by me
		PullRequest: "🟧", //codespell-ignore
		// biome-ignore lint/style/useNamingConvention: not by me
		Issue: "🔵",
	};
	const reasonMaps = {
		author: "👤",
		mention: "❗",
		subscribed: "🔔",
		comment: "💬",
	};

	/** @type AlfredItem[] */
	const notifications = responseObj.map((/** @type {GithubNotif} */ notif) => {
		const url = notif.subject.url
			.replace("https://api.github.com/repos/", "https://github.com/")
			.replace("pulls/", "pull/");
		const typeIcon = typeMaps[notif.subject.type] || notif.subject.type;
		const reasonIcon = reasonMaps[notif.reason] || notif.reason;
		const deltaSecs = (+new Date(notif.updated_at) - +new Date());
		const updatedAt = 

		const subtitle = `${typeIcon} ${reasonIcon}  ${notif.repository.name} ${updatedAt}`;
		return {
			title: notif.subject.title,
			subtitle: subtitle,
			arg: url,
			mods: {
				cmd: { arg: notif.id },
			},
		};
	});

	return JSON.stringify({
		items: notifications,
		variable: { notificationsLeft: notifications.length - 1 },
	});
}
