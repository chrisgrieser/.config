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
	const isBaseFolderSearch =
		$.getenv("alfred_workflow_keyword") === $.getenv("base_folder_keyword");
	const folderToSearch = isBaseFolderSearch ? $.getenv("base_folder") : app.pathTo("home folder");
	const maxItems = isBaseFolderSearch ? -1 : 20;
	const rgCmd = // INFO `fd` does not allow to sort results by recency, thus using `rg` instead
		"rg --no-config --files --sortr=modified --glob='!/Library/' --glob='!*.photoslibrary'";

	const results = app
		.doShellScript(`cd '${folderToSearch}' && ${rgCmd}`)
		.split("\r")
		.slice(0, maxItems)
		.map((relPath) => {
			const [_, parent, name] = relPath.match(/(.*\/)(.*\/?)/) || [];
			const absPath = folderToSearch + "/" + relPath;

			return {
				title: name,
				subtitle: parent.slice(0, -1),
				arg: absPath,
				type: "file:skipcheck",
				match: alfredMatcher(name),
				icon: extensionToAlfredIcon(absPath),
			};
		});

	return JSON.stringify({ items: results });
}
