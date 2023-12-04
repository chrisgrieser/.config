#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const frontmostAppName = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0];
const frontmostApp = Application(frontmostAppName);

function browserTab() {
	// biome-ignore format: long
	const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc"];
	const webkitVariants = ["Safari", "Webkit"];
	let title, url;
	if (chromiumVariants.some((appName) => frontmostAppName.startsWith(appName))) {
		// @ts-ignore
		url = frontmostApp.windows[0].activeTab.url();
		// @ts-ignore
		title = frontmostApp.windows[0].activeTab.name();
	} else if (webkitVariants.some((appName) => frontmostAppName.startsWith(appName))) {
		// @ts-ignore
		url = frontmostApp.documents[0].url();
		// @ts-ignore
		title = frontmostApp.documents[0].name();
	} else {
		app.displayNotification("", { withTitle: "You need a supported browser as your frontmost app", subtitle: "" });
		return;
	}
	return { url: url, title: title };
}


//──────────────────────────────────────────────────────────────────────────────

const url = browserTab().url;
frontmostApp.includeStandardAdditions = true;
const domain = $.getenv("sci_hub_domain")
frontmostApp.openLocation(`https://sci-hub.${domain}/${url}`);
frontmostApp.openLocation(`https://annas-archive.org/search?q=${encodeURI(url)}`);
