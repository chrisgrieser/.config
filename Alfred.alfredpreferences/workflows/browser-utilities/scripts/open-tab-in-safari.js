#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────
function browserTab() {
	const frontmostAppName = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0];
	const frontmostApp = Application(frontmostAppName);
	const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc"];
	let title, url;
	if (chromiumVariants.some((appName) => frontmostAppName.startsWith(appName))) {
		url = frontmostApp.windows[0].activeTab.url();
		title = frontmostApp.windows[0].activeTab.name();
	} else {
		app.displayNotification("", { withTitle: "You need a supported browser as your frontmost app", subtitle: "" });
		return;
	}
	return { url: url, title: title };
}
browserTab().url;
