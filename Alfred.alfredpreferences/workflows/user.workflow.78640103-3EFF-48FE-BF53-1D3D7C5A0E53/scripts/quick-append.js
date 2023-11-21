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
	const tot = Application("Tot");
	tot.includeStandardAdditions = true;

	const quicksaveDot = $.getenv("quicksave_dot");
	const appendPrefix = $.getenv("append_prefix");
	const isBrowser = frontBrowser() !== "no browser";

	// get selected text
	const keywordUsed = Boolean(argv[0]);
	let selectedText;
	if (keywordUsed) {
		selectedText = argv[0];
	} else {
		app.setTheClipboardTo(""); // empty clipboard in case of no selection
		Application("System Events").keystroke("c", { using: ["command down"] });
		delay(0.05);
		selectedText = app.theClipboard().toString();
	}

	// GUARD
	if (!(selectedText || isBrowser)) return "";

	// determine text
	let text = "\n" + appendPrefix + selectedText;
	if (isBrowser) {
		const { url, title } = browserTab();
		const mdlink = `[${title}](${url})`;
		const sep = selectedText ? " " : "";
		text += sep + mdlink;
	}

	// append
	const empty = tot.openLocation(`tot://${quicksaveDot}/content`).match(/^\s*$/);
	if (empty) {
		text.trim(); 
		tot.openLocation(`tots://${quicksaveDot}/replace?text=${encodeURIComponent(text)}`);
	} else {
		tot.openLocation(`tots://${quicksaveDot}/append?text=${encodeURIComponent(text)}`);
	} 

	// hide the app
	const totProcess = Application("System Events").applicationProcesses.byName("Tot");
	totProcess.visible = false

	// Pass for Alfred notification
	return text;
}
