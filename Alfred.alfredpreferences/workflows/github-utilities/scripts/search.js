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

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const notifications = httpRequest("https://api.github.com/notifications", [
		"Accept: application/vnd.github.v3+json",
		"Authorization: BEARER " + $.getenv("github_token"),
	])
		.split("\r")
		.map((item) => {
			return {
				title: item,
				subtitle: item,
				arg: item,
			};
		});
	return JSON.stringify({ items: notifications });
}
