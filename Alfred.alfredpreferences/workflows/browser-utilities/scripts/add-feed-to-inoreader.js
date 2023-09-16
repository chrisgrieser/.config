#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	let url;

	if (argv[0]) {
		// no input = take URL from browser
		url = argv[0];
	} else {
		const frontmostAppName = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0];
		const frontmostApp = Application(frontmostAppName);
		const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge"];
		const webkitVariants = ["Safari", "Webkit"];
		if (chromiumVariants.some((appName) => frontmostAppName.startsWith(appName))) {
			url = frontmostApp.windows[0].activeTab.url();
		} else if (webkitVariants.some((appName) => frontmostAppName.startsWith(appName))) {
			url = frontmostApp.documents[0].url();
		} else {
			app.displayNotification("", { withTitle: "You need a supported browser as your frontmost app", subtitle: "" });
			return;
		}
	}

	const inoreaderURL = "https://www.inoreader.com/search/feeds/" + encodeURIComponent(url);
	app.openLocation(inoreaderURL);
}
