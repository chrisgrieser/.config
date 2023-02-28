#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const iconFolder =
	app.pathTo("home folder") + "/Library/Mobile Documents/com~apple~CloudDocs/Dokumente/Icon Collection";
const customIconFolder = iconFolder + "/custom-app-icons";
const filetypeIconFolder = iconFolder + "/custom-filetype-icons";

//──────────────────────────────────────────────────────────────────────────────

// `-H` to follow symlinks
const workArray1 = app.doShellScript(`find "${iconFolder}" -name "*.icns" -or -name "*.png" `).split("\r");
const workArray2 = app.doShellScript(`find -H "${customIconFolder}" -name "*.icns" -or -name "*.png" `).split("\r");
const workArray3 = app.doShellScript(`find -H "${filetypeIconFolder}" -name "*.icns" -or -name "*.png" `).split("\r");
const allIcons = [...workArray1, ...workArray2, ...workArray3].map(iconPath => {
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

JSON.stringify({ items: allIcons });
