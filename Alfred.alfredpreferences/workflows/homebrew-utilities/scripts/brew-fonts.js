#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replaceAll("-", " ");
	return clean + " " + str;
}

//──────────────────────────────────────────────────────────────────────────────

const githubApiUrl = "https://api.github.com/repos/Homebrew/homebrew-cask-fonts/git/trees/master?recursive=1";

const workArray = JSON.parse(app.doShellScript(`curl -sL "${githubApiUrl}"`))
	.tree.filter(file => file.path.startsWith("Casks/"))
	.map(entry => {
		const fontname = entry.path.slice(11, -3); /* eslint-disable-line no-magic-numbers */
		const cask = "font-" + fontname;

		return {
			title: fontname,
			match: alfredMatcher(fontname),
			arg: cask,
			uid: cask,
		};
	});

JSON.stringify({ items: workArray });
