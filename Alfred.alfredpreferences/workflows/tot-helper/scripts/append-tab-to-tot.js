#!/usr/bin/env osascript -l JavaScript

function browserTab() {
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	const frontmostAppName = Application("System Events")
		.applicationProcesses.where({ frontmost: true })
		.name()[0];
	const frontmostApp = Application(frontmostAppName);
	// biome-ignore format: no
	const chromiumVariants = [ "Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc" ];
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
		app.displayNotification("", { withTitle: "Frontmost app is not a supported browser.", subtitle: "" });
		return;
	}
	return { url: url, title: title };
}


let quicker_save = "^"
console.log("🪚 quicker_save:", quicker_save);

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const selectedText = argv[0] + "\n" || "";
	const { url, title } = browserTab();
	const mdlink = `[${title}](${url})`;
	const quicksave_dot = $.getenv("quicksave_dot");

	const tot = Application("Tot");
	tot.includeStandardAdditions = true;
	const linebreakAtEnd = tot.openLocation(`tot://${quicksave_dot}/content`).endsWith("\n")
	const lb = linebreakAtEnd ? "" : "\n";
	const text = lb + selectedText + mdlink;
	tot.openLocation(`tot://${quicksave_dot}/append?text=${text}`);
}
