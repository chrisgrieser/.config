#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const iconFolder = app.pathTo("home folder") + "/Library/Mobile Documents/com~apple~CloudDocs/Images/Icon Collection";

//──────────────────────────────────────────────────────────────────────────────

const workArray = app
	// `-L` to follow symlinks
	.doShellScript(`find -L "${iconFolder}" -name "*.icns" -or -name "*.png" `)
	.split("\r")
	.map(iconPath => {
		const filename = iconPath.replace(/.*\//, "");
		const shortenedPath = iconPath.replace(/\/Users\/.*?\//g, "~/");
		return {
			title: filename,
			subtitle: shortenedPath,
			arg: iconPath,
			icon: { path: iconPath },
			type: "file:skipcheck",
			uid: iconPath,
		};
	});

JSON.stringify({ items: workArray });
