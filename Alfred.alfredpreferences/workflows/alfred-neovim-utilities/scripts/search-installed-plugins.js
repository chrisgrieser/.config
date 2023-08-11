#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const pluginLocation = $.getenv("plugin_installation_path");
	const jsonArray = app
		.doShellScript(
			`cd "${pluginLocation}" && grep --only-matching --no-filename --max-count=1 "http.*" ./*/.git/config`,
		)
		.split("\r")
		.map((remote) => {
			const owner = remote.split("/")[3];
			const name = remote.split("/")[4].slice(0, -4); // remove ".git"
			const repo = `${owner}/${name}`;
			return {
				title: name,
				subtitle: owner,
				match: alfredMatcher(repo),
				arg: repo,
				uid: repo,
			};
		});

	return JSON.stringify({ items: jsonArray });
}
