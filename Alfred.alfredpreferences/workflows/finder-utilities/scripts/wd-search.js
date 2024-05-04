#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const defaultFolder = $.getenv("base_folder");

	const workArray = app
		.doShellScript(
			`cd "${defaultFolder}" && find . -not -name ".DS_Store" -not -name ".localized" -mindepth 1 -maxdepth 1`,
		)
		.split("\r")
		.map((item) => {
			const itemPath = defaultFolder + item.slice(1);
			const extension = item.split(".").pop() || "";
			const fileName = item.slice(2);

			const imageExtensions = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic"];
			const iconToDisplay = imageExtensions.includes(extension)
				? { path: itemPath }
				: { path: itemPath, type: "fileicon" };

			return {
				title: fileName,
				icon: iconToDisplay,
				type: "file:skipcheck",
				arg: itemPath,
			};
		});

	return JSON.stringify({ items: workArray });
}
