#!/usr/bin/env osascript -l JavaScript

//──────────────────────────────────────────────────────────────────────────────
function run() {
	const frontmostAppName = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0];
	const frontmostApp = Application(frontmostAppName);
	const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge"];
	const webkitVariants = ["Safari", "Webkit"];
	let url;
	if (chromiumVariants.some(appName => frontmostAppName.startsWith(appName))) {
		url = frontmostApp.windows[0].activeTab.url();
	} else if (webkitVariants.some(appName => frontmostAppName.startsWith(appName))) {
		url = frontmostApp.documents[0].url();
	} else {
		return "You need a supported browser as your frontmost app.";
	}

	if (!url.match(/^https?:\/\/github\.com\/\w+\/\w+/)) {
		return "Not a GitHub Repo.";
	}
	return url;
}
