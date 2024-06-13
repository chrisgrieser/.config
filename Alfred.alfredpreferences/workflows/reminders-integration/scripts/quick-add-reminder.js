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
	// biome-ignore format: too long
	const chromiumVariants = [ "Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc" ];
	const webkitVariants = ["Safari", "Webkit"];
	const isChromium = chromiumVariants.some((appName) => frontAppName.startsWith(appName));
	const isWebKit = webkitVariants.some((appName) => frontAppName.startsWith(appName));

	if (isChromium) return "chromium";
	if (isWebKit) return "webkit";
	return "no browser";
}

function browserTab() {
	const frontmostApp = Application(getFrontAppName());
	const browserType = frontBrowser();

	let title;
	let url;
	if (browserType === "chromium") {
		// @ts-expect-error
		url = frontmostApp.windows[0].activeTab.url();
		// @ts-expect-error
		title = frontmostApp.windows[0].activeTab.name();
	} else if (browserType === "webkit") {
		// @ts-expect-error
		url = frontmostApp.documents[0].url();
		// @ts-expect-error
		title = frontmostApp.documents[0].name();
	} else {
		return { url: "", title: "" };
	}
	return { url: url, title: title };
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const isBrowser = frontBrowser() !== "no browser";
	const keywordUsed = Boolean(argv[0]);
	let remTitle = "";
	let remBody = "";
	const remList = $.getenv("rem_list");

	if (keywordUsed) {
		remTitle = argv[0] || "";
	} else {
		// get selected text
		app.setTheClipboardTo(""); // empty clipboard in case of no selection
		Application("System Events").keystroke("c", { using: ["command down"] });
		delay(0.1);
		remTitle = app.theClipboard().toString();
	}

	// GUARD
	if (!remTitle && !isBrowser) return "";

	// add rem for today
	if (isBrowser) {
		const { url, title } = browserTab();
		remBody = url;
		remTitle = title;
	}

	app.doShellScript(`rems add "${remList}" "${remTitle}" --due-date="today" ${remBody}`);

	// Pass for Alfred notification
	return remTitle;
}
