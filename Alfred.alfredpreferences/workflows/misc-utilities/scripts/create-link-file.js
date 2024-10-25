#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const currentTab = Application("Brave Browser").windows[0].activeTab;

	const sel = argv[0].trim();
	const url = currentTab.url();
	const title = currentTab.name().replace(/ \| .*/g, "");
	const toCopy = `> ${sel} – [${title}](${url})`;

	app.setTheClipboardTo(toCopy);
	return toCopy; // pass to Alfred for notification
}
