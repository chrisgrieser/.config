#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const iconFolder = $.getenv("icon_folder").replace(/^~/, app.pathTo("home folder"));
const customIconFolder = $.getenv("custom_icon_folder").replace(/^~/, app.pathTo("home folder"));

const workArray1 = app.doShellScript("find \"" + iconFolder + "\" -name \"*.icns\" -or -name \"*.png\" ")
	.split("\r");
const workArray2 = app.doShellScript("find \"" + customIconFolder + "\" -name \"*.icns\" -or -name \"*.png\" ")
	.split("\r");
const bothArrays = [...workArray1, ...workArray2]
	.map(iconPath => {
		const filename = iconPath.replace (/.*\//, "");
		const shortenedPath = iconPath.replace (/\/Users\/.*?\//g, "~/");
		return {
			"title": filename,
			"subtitle": shortenedPath,
			"arg": iconPath,
			"icon": { "path": iconPath },
			"type": "file:skipcheck",
			"uid": iconPath,
		};
	});

JSON.stringify({ items: bothArrays });
