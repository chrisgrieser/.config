#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const home = app.pathTo("home folder")
const memeFolder = home + "/Library/Mobile Documents/com~apple~CloudDocs/Images/Memes";

//──────────────────────────────────────────────────────────────────────────────

const workArray = app
	.doShellScript(`find "${memeFolder}" -name "*.icns" -or -name "*.png" `)
	.split("\r")
	.map(imagePath => {
		const filename = imagePath.replace(/.*\//, "");
		const shortenedPath = imagePath.replace(/\/Users\/.*?\//g, "~/");
		return {
			title: filename,
			subtitle: shortenedPath,
			arg: imagePath,
			icon: { path: imagePath },
			type: "file:skipcheck",
			uid: imagePath,
		};
	});

JSON.stringify({ items: workArray });
