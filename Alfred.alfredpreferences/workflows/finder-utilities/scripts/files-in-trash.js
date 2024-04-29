#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function camelCaseMatch(str) {
	const subwords = str.replace(/[-_./]/g, " ");
	const fullword = str.replace(/[-_./]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " ");
	return [subwords, camelCaseSeparated, fullword, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const home = app.pathTo("home folder");
	const trashLocation1 = home + "/.Trash";
	const trashLocation2 = home + "/Library/Mobile Documents/.Trash";

	const trashedFile = app
		.doShellScript(`find "${trashLocation1}" "${trashLocation2}" -maxdepth 1 -mindepth 1`)
		.split("\r")
		.map((path) => {
			const ext = path.split(".").pop() || "";
			const filename = path.split("/").pop();

			const imageExtensions = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic"];
			const iconToDisplay = imageExtensions.includes(ext)
				? { path: path }
				: { path: path, type: "fileicon" };

			return {
				title: filename,
				match: camelCaseMatch(path),
				icon: iconToDisplay,
				type: "file:skipcheck",
				arg: path,
			};
		});

	return JSON.stringify({ items: trashedFile });
}
