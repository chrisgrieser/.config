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
function httpRequest(url, header) {
	let allHeaders = "";
	for (const line of header) {
		allHeaders += `-H "${line}" `;
	}
	const curlRequest = `curl -L ${allHeaders} "${url}"`;
	const response = app.doShellScript(curlRequest);
	return response;
}

/** @typedef {Object} githubNotification
 * @property {{type: string, url: string, title: string}} subject
 * @property {{name: string}} repository
 * @property {string} reason
 */

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
	const response = httpRequest("https://api.github.com/notifications", [
		"Accept: application/vnd.github.v3+json",
		`Authorization: BEARER ${githubToken}`,
		"X-GitHub-Api-Version: 2022-11-28",
	]);
	const responseObj = JSON.parse(response);
	if (responseObj.length === 0) {
		return JSON.stringify({
			items: [{ title: "No unread notifications.", valid: false }],
		});
	}

	/** @type AlfredItem[] */
	const notifications = responseObj.map((/** @type {githubNotification} */ notif) => {
		const subtitle = `${notif.repository.name} · ${notif.subject.type} · ${notif.reason} `;
		const url = notif.subject.url
			.replace("https://api.github.com/repos/", "https://github.com/")
			.replace("pulls/", "pull/");
		return {
			title: notif.subject.title,
			subtitle: subtitle,
			arg: url,
		};
	});

	return JSON.stringify({ items: notifications });
}
