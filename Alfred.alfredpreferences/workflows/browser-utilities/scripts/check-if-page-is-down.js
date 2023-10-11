#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

function getFrontAppName() {
	return Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0];
}

function frontBrowser() {
	const frontAppName = getFrontAppName();
	// biome-ignore format: -
	const chromiumVariants = [ "Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc" ];
	const webkitVariants = ["Safari", "Webkit"];
	const isChromium = chromiumVariants.some((appName) => frontAppName.startsWith(appName));
	const isWebKit = webkitVariants.some((appName) => frontAppName.startsWith(appName));

	if (isChromium) return "chromium";
	else if (isWebKit) return "webkit";
	return "no browser";
}

function browserTab() {
	const frontmostApp = Application(getFrontAppName());
	const browserType = frontBrowser();

	let title, url;
	if (browserType === "chromium") {
		// @ts-ignore
		url = frontmostApp.windows[0].activeTab.url();
		// @ts-ignore
		title = frontmostApp.windows[0].activeTab.name();
	} else if (browserType === "webkit") {
		// @ts-ignore
		url = frontmostApp.documents[0].url();
		// @ts-ignore
		title = frontmostApp.documents[0].name();
	} else {
		app.displayNotification("", { withTitle: "Frontmost app is not a supported browser.", subtitle: "" });
		return;
	}
	return { url: url, title: title };
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const isBrowser = frontBrowser() !== "no browser";
	const url = isBrowser ? browserTab().url : argv[0];
	app.openLocation("https://downforeveryoneorjustme.com/" + url);
}
