#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const tagName = $.getenv("tag_to_search");

	const taggedFiles = app
		// https://www.alfredforum.com/topic/18041-advanced-search-using-tags-%C3%A0-la-finder/
		.doShellScript(`mdfind "kMDItemUserTags == ${tagName}"`)
		.split("\r")
		.map((path) => {
			const fileName = path.split("/").pop() || "";
			const ext = fileName.split(".").pop() || "";
			let parentFolder = path.split("/").slice(0, -1).join("/");
			parentFolder = parentFolder
				.replace(/\/Users\/\w+\/Library\/Mobile Documents\/com~apple~CloudDocs/, "☁️")
				.replace(/\/Users\/\w+/, "~");

			const iconToDisplay = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic"].includes(ext)
				? { type: "fileicon", path: path }
				: { path: path };

			return {
				title: fileName + " " + $.getenv("tag_emoji"),
				subtitle: parentFolder,
				icon: iconToDisplay,
				type: "file:skipcheck",
				uid: path,
				arg: path,
			};
		});

	return JSON.stringify({ items: taggedFiles });
}
