#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;

const frontmostAppName = Application("System Events")
	.applicationProcesses.where({ frontmost: true })
	.name()[0];
const frontmostApp = Application(frontmostAppName);
frontmostApp.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

function browserTab() {
	// rome-ignore format: A
	const chromiumVariants = [ "Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc" ];
	const webkitVariants = ["Safari", "Webkit"];
	let title, url;
	if (chromiumVariants.some((appName) => frontmostAppName.startsWith(appName))) {
		url = frontmostApp.windows[0].activeTab.url();
		title = frontmostApp.windows[0].activeTab.name();
	} else if (webkitVariants.some((appName) => frontmostAppName.startsWith(appName))) {
		url = frontmostApp.documents[0].url();
		title = frontmostApp.documents[0].name();
	} else {
		app.displayNotification("", {
			withTitle: "You need a supported browser as your frontmost app",
			subtitle: "",
		});
		return null;
	}
	return { url: url, title: title };
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const tab = browserTab();
	if (!tab) return;

	const url = browserTab().url;
	const title = browserTab().title;

	// Google to get there via the first link maybe
	frontmostApp.openLocation("https://www.google.com/search?q=" + encodeURIComponent(title));

	// Try various Paywall skippers
	frontmostApp.openLocation("https://12ft.io/" + url);
	frontmostApp.openLocation("https://www.spaywall.com/search/" + url);
	frontmostApp.openLocation("https://archive.li/" + url);

	// Reader Mode, if supported
	frontmostApp.menuBars[0].menuBarItems.byName("View").menus[0].menuItems.byName("Enter Reader Mode").click();
}
