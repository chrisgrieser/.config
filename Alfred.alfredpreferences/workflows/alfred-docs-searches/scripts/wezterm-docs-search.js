#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const docsURL = "https://api.github.com/repos/wez/wezterm/git/trees/main?recursive=1";
	const baseURL = "https://wezfurlong.org/wezterm";
	const docPathRegex = /^docs\/.*\.md$/i;

	const workArray = JSON.parse(app.doShellScript(`curl -s "${docsURL}"`))
		.tree.filter((/** @type {{ path: string; }} */ file) => docPathRegex.test(file.path))
		.reverse()
		.map((/** @type {{ path: string }} */ entry) => {
			const subsite = entry.path.slice(5, -3);
			const parts = subsite.split("/");
			let displayTitle = parts.pop().replace(/[-_]/g, " ");
			displayTitle = displayTitle.charAt(0).toUpperCase() + displayTitle.slice(1);
			const category = parts.join("/");
			const url = `${baseURL}/${subsite}`;

			return {
				title: displayTitle,
				subtitle: category,
				match: alfredMatcher(subsite),
				arg: url,
				uid: subsite,
			};
		});

	return JSON.stringify({ items: workArray });
}
