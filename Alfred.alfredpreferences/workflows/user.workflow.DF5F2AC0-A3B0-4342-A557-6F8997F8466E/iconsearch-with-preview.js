#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const home = app.pathTo("home folder");

//──────────────────────────────────────────────────────────────────────────────

const iconFolder = home + "/Library/Mobile Documents/com~apple~CloudDocs/Dokumente/Icon Collection";
const customIconFolder = home + "/.config/custom-app-icons"

//──────────────────────────────────────────────────────────────────────────────

const workArray1 = app.doShellScript('find "' + iconFolder + '" -name "*.icns" -or -name "*.png" ').split("\r");
const workArray2 = app.doShellScript('find "' + customIconFolder + '" -name "*.icns" -or -name "*.png" ').split("\r");
const bothArrays = [...workArray1, ...workArray2].map(iconPath => {
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

JSON.stringify({ items: bothArrays });
