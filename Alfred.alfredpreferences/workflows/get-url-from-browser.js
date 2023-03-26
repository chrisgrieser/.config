#!/usr/bin/env osascript -l JavaScript
// INFO placed in parent folder of all Alfred workflwos for easy access

//──────────────────────────────────────────────────────────────────────────────
function run() {
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	const frontmostAppName = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0];
	const frontmostApp = Application(frontmostAppName);
	const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Brave Browser", "Vivaldi", "Microsoft Edge"];
	const webkitVariants = ["Safari", "Webkit"];
	let url;
	if (chromiumVariants.some(appName => frontmostAppName.startsWith(appName))) {
		url = frontmostApp.windows[0].activeTab.url();
	} else if (webkitVariants.some(appName => frontmostAppName.startsWith(appName))) {
		url = frontmostApp.documents[0].url();
	} else {
		app.displayNotification("", { withTitle: "Browser not supported.", subtitle: frontmostAppName });
	}
	return url;
}
