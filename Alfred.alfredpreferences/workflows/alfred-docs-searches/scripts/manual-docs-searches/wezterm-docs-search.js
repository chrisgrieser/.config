#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_]/g, " ");
	return [clean, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const docsURL = "https://api.github.com/repos/wez/wezterm/git/trees/main?recursive=1";
	const baseURL = "https://wezterm.org";
	const docPathRegex = /^docs\/.*\.md$/i;

	const workArray = JSON.parse(app.doShellScript(`curl -sL "${docsURL}"`))
		.tree.filter((/** @type {{ path: string; }} */ file) => docPathRegex.test(file.path))
		.reverse()
		.map((/** @type {{ path: string }} */ entry) => {
			const entryPath = entry.path.slice(5, -3);
			const parts = entryPath.split("/");
			const title = parts.pop() || "??";
			const category = parts.join("/");
			const url = `${baseURL}/${entryPath}`;

			return {
				title: title,
				subtitle: category,
				match: alfredMatcher(entryPath),
				mods: {
					cmd: { arg: entryPath }, // copy entry
				},
				arg: url,
				quicklookurl: url,
				uid: entryPath,
			};
		});

	return JSON.stringify({
		items: workArray,
		cache: {
			seconds: 3600 * 24 * 7, // 7 days
			loosereload: true,
		},
	});
}
