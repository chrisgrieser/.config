#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_().:#;,[\]'"]/g, " ");
	return [clean, str].join(" ") + " ";
}

/** @param {string} path */
function extensionToAlfredIcon(path) {
	const ext = path.split(".").pop() || "";
	const imageExtensions = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic"];
	return imageExtensions.includes(ext) ? { path: path } : { path: path, type: "fileicon" };
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
		.map((absPath) => {
			const filename = absPath.split("/").pop();

			return {
				title: filename,
				match: alfredMatcher(absPath),
				icon: extensionToAlfredIcon(absPath),
				type: "file:skipcheck",
				arg: absPath,
			};
		});

	return JSON.stringify({ items: trashedFile });
}
