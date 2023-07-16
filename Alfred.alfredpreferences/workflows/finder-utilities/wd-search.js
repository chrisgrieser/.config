#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────
const defaultFolder = $.getenv("default_folder").replace(/^~/, app.pathTo("home folder"));

const workArray = app
	.doShellScript(`cd "${defaultFolder}" && find . -not -name ".DS_Store" -mindepth 1 -maxdepth 1`)
	.split("\r")
	.map(item => {
		const itemPath = defaultFolder + item.slice(1);
		const extension = item.split(".").pop();

		const iconToDisplay = { path: itemPath };
		const imageExtensions = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic", "pdf"];
		if (!imageExtensions.includes(extension)) iconToDisplay.type = "fileicon";

		return {
			title: item.slice(2),
			match: alfredMatcher(item),
			type: "file:skipcheck",
			arg: itemPath,
			icon: iconToDisplay,
		};
	});

JSON.stringify({ items: workArray });
