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
	const folderToSearch = $.getenv("base_folder");
	const rgCmd = "rg --no-config --files --sortr=modified";

	const workArray = app
		.doShellScript(`cd '${folderToSearch}' && ${rgCmd}`)
		.split("\r")
		.map((relPath) => {
			const [_, parent, name] = relPath.match(/(.*\/)(.*\/?)/) || [];
			const absPath = folderToSearch + "/" + relPath;

			return {
				title: name,
				subtitle: parent.slice(0, -1),
				type: "file:skipcheck",
				arg: absPath,
				match: alfredMatcher(name),
				icon: extensionToAlfredIcon(absPath),
			};
		});

	return JSON.stringify({ items: workArray });
}
