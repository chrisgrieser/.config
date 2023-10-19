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
	const [githubToken, threadId] = argv;
	// DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#mark-a-thread-as-read
	httpRequestWithHeaders(
		`https://api.github.com/notifications/threads/${threadId}`,
		[
			"Accept: application/vnd.github+json",
			`Authorization: BEARER ${githubToken}`,
			"X-GitHub-Api-Version: 2022-11-28",
		],
		"-X PATCH",
	);
}
