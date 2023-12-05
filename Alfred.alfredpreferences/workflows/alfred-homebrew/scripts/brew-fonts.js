#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replaceAll("-", " ");
	return clean + " " + str;
}

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const githubApiUrl =
		"https://api.github.com/repos/Homebrew/homebrew-cask-fonts/git/trees/master?recursive=1";

	const installedFonts = app
		.doShellScript('cd "$(brew --prefix)" ; ls -1 ./Caskroom') // PERF `ls` quicker than `brew list`
		.split("\r")
		.filter((/** @type {string} */ name) => name.startsWith("font-"));

	const fonts = JSON.parse(httpRequest(githubApiUrl))
		.tree.filter((/** @type {{ path: string; }} */ file) => file.path.startsWith("Casks/"))
		.map((/** @type {{ path: string }} */ entry) => {
			const fontname = entry.path.slice(6, -3);
			const displayName = fontname.slice(5); // remove "font-" prefix
			const isNerdFont = fontname.includes("nerd-font") || fontname.endsWith("-nf");

			let icon = isNerdFont ? " 🙂" : "";
			if (installedFonts.includes(fontname)) icon += " ✅";

			let matcher = alfredMatcher(displayName);
			if (isNerdFont) matcher += " nerdfont";

			return {
				title: displayName + icon,
				match: matcher,
				arg: fontname,
				uid: fontname,
			};
		});

	return JSON.stringify({ items: fonts });
}
