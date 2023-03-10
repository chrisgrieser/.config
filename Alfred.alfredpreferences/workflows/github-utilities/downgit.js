#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	const browser = Application("Vivaldi");
	const url = argv[0].trim();

	const downgitURL = "https://downgit.evecalm.com/#/home?url=" + encodeURIComponent(url)
	browser.windows[0].activeTab.url = downgitURL; // replace url
}
