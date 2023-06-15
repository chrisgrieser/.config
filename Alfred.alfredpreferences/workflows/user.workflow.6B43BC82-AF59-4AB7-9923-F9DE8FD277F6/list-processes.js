#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const processes = app.doShellScript("ps rcAo '%cpu=,%mem=,command='")
	.split("\r")
	.map((/** @type {string} */ processInfo) => {
		const info = processInfo.trim().split(/\s+/);
		const cpu = info[0];
		const memory = info[1];
		const name = info[2];
		
		return {
			title: name,
			subtitle: `CPU: ${cpu}     MEM: ${memory}`,
			arg: name,
		};
	});

JSON.stringify({
	rerun: 2, // rerun every 2 secs
	items: processes,
});
