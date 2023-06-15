#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const apps = app.doShellScript("ls /Applications/");

const processes = app
	.doShellScript("ps rcAo 'pid=,%cpu=,%mem=,command='")
	.split("\r")
	.map((/** @type {string} */ processInfo) => {
		const info = processInfo.trim().split(/\s+/);
		const pid = info[0];
		const cpu = info[1];
		const memory = info[2];
		let name = info[3];

		// app icons
		switch (name) {
			case "<defunct>":
				return {};
			case "Alfred":
				name += " 5";
				break;
			case "neovide":
			case "espanso":
				name = name.charAt(0).toUpperCase() + name.slice(1); // capitalize
				break;
			case "wezterm-gui":
				name = "WezTerm";
				break;
		}
		const isApp = apps.includes(name);
		const icon = isApp ? { type: "fileicon", path: `/Applications/${name}.app` } : {};

		return {
			title: name,
			subtitle: `📈 ${cpu}    📊 ${memory}`,
			icon: icon,
			arg: pid,
		};
	});

JSON.stringify({
	rerun: 2.5, // seconds (only 0.1 - 5)
	items: processes,
});
