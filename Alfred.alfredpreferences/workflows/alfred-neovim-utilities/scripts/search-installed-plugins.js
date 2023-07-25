#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

const pluginLocation = $.getenv("plugin_installation_path").replace(/^~/, app.pathTo("home folder"));
const jsonArray = app
	.doShellScript(`
		find "${pluginLocation}" -path "*/.git" -type d -maxdepth 3 | while read -r line ; do
			cd "$line"/..
			git remote -v | head -n1
		done`)
	.split("\r")
	.map((remote) => {
		const repo = remote
			.slice(26, -12) /* eslint-disable-line no-magic-numbers */
			.replaceAll(".git (fetch)", ""); // for lazy.nvim
		const name = repo.split("/")[1];
		const owner = repo.split("/")[0];
		return {
			title: name,
			subtitle: owner,
			match: alfredMatcher(repo),
			arg: repo,
			uid: repo,
		};
	});

JSON.stringify({ items: jsonArray });
