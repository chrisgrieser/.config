#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const defaultFolder = $.getenv("base_folder");

	const workArray = app
		.doShellScript(`cd "${defaultFolder}" && find . -not -name ".DS_Store" -mindepth 1 -maxdepth 1`)
		.split("\r")
		.map((item) => {
			const itemPath = defaultFolder + item.slice(1);
			const extension = item.split(".").pop();
			const fileName = item.slice(2)

			const iconToDisplay = { path: itemPath };
			const imageExtensions = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic"];
			if (!imageExtensions.includes(extension)) iconToDisplay.type = "fileicon";

			return {
				title: fileName,
				icon: iconToDisplay,
				type: "file:skipcheck",
				arg: itemPath,
			};
		});

	return JSON.stringify({ items: workArray });
}
