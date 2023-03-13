#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;


function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

const defaultFolder = $.getenv("default_folder").replace(/^~/, app.pathTo("home folder"));

const workArray = app
	.doShellScript(`ls -1 '${defaultFolder}'`)
	.split("\r")
	.map(item => {
		const itemPath = defaultFolder + "/" + item;
		const extension = item.split(".").pop();
		const imageExtensions = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic", "pdf"];

		let iconToDisplay;
		if (imageExtensions.includes(extension)) iconToDisplay = { path: itemPath };
		else iconToDisplay = { type: "fileicon", path: itemPath };

		return {
			title: item,
			match: alfredMatcher(item),
			type: "file:skipcheck",
			arg: itemPath,
			icon: iconToDisplay,
		};
	});

JSON.stringify({ items: workArray });
