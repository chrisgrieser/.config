#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	const selection = argv[0];
	const url = Application("Vivaldi").windows[0].activeTab.url();
	const title = Application("Vivaldi").windows[0].activeTab.title();

	const out = [title, url];
	if (selection) out.unshift("> " + selection)

	return out.join("\n");
}
