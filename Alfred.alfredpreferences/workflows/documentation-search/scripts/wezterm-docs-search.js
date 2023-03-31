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

const docsURL = "https://api.github.com/repos/wez/wezterm/git/trees/main?recursive=1";
const baseURL = "https://wezfurlong.org/wezterm";
const docPathRegex = /^docs\/.*\.md$/i;

const workArray = JSON.parse(app.doShellScript(`curl -s "${docsURL}"`))
	.tree.filter(file => docPathRegex.test(file.path))
	.map(entry => {
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

JSON.stringify({ items: workArray });
