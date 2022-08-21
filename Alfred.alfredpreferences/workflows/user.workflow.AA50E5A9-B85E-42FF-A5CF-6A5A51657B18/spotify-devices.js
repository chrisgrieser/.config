#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
const currentDevice = app.doShellScript("spt playback --status --format=%d").trim();
const activeIcon = "🔊";
const devices = app.doShellScript("spt list --devices")
	.split("\r")
	.map(device => {
		const name = device.replace(/\d+% /, "");
		const volume = device.replace(/(\d+%) .*/, "$1");
		let suffix = "";
		if (name === currentDevice) suffix = " " + activeIcon;
		return {
			"title": name + suffix,
			"subtitle": volume,
			"match": alfredMatcher (name),
			"arg": name,
			"uid": name,
		};
	})
	// sort selected device up top
	.sort((a, b) => {
		const icon = " " + activeIcon;
		if (a.title.endsWith(icon) && !b.title.endsWith(icon)) return -1;
		if (!a.title.endsWith(icon) && b.title.endsWith(icon)) return 1;
		return 0;
	});

JSON.stringify({ items: devices });


