#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

function browserTab() {
	const frontmostAppName = Application("System Events")
		.applicationProcesses.where({ frontmost: true })
		.name()[0];
	const frontmostApp = Application(frontmostAppName);
	// rome-ignore format: long
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
		return;
	}
	return { url: url, title: title };
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {

	// get selection
	app.doShellScript("pbcopy < /dev/null"); // empty the clipboard
	try {
		Application("System Events").keystroke("c", { using: ["command down"] });
	} catch (_error) {}
	delay(0.15); // ensure the clipboard is available
	const selection = app.theClipboard();

	// compose mailto-URI
	const { url, title } = browserTab();
	const mailBody = selection ? `> "${selection}"\n\n${url}` : url;
	return `mailto:?subject=FYI: ${title}&body=${mailBody}`;
}
