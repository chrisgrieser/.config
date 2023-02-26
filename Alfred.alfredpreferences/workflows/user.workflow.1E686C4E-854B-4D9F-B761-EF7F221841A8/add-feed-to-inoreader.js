#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	//───────────────────────────────────────────────────────────────────────────

	let url;

	// no input = take URL from browser
	if (argv) {
		url = argv[0];
	} else {
		const frontmostAppName = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0];
		const frontmostApp = Application(frontmostAppName);
		const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge"];
		const webkitVariants = ["Safari", "Webkit"];
		if (chromiumVariants.some(appName => frontmostAppName.startsWith(appName))) {
			url = frontmostApp.windows[0].activeTab.url();
		} else if (webkitVariants.some(appName => frontmostAppName.startsWith(appName))) {
			url = frontmostApp.documents[0].url();
		} else {
			app.displayNotification("", { withTitle: "You need a supported browser as your frontmost app", subtitle: "" });
			return;
		}
	}

	const inoreaderURL = "https://www.inoreader.com/search/feeds/" + encodeURIComponent(url);
	app.openLocation(inoreaderURL);
}
