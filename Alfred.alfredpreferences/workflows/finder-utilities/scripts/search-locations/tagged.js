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
	return imageExtensions.includes(ext)
		? { path: path }
		: { path: path, type: "fileicon" };
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const tagName = $.getenv("tag_to_search");
	// https://www.alfredforum.com/topic/18041-advanced-search-using-tags-%C3%A0-la-finder/
	const tagged = app.doShellScript(`mdfind "kMDItemUserTags == ${tagName}"`);

	// GUARD
	if (!tagged) {
		return JSON.stringify({
			items: [{ title: `No item with "${tagName}" not found` }],
		});
	}

	const taggedFiles = tagged.split("\r").map((path) => {
		const fileName = path.split("/").pop() || "";
		let parentFolder = path.split("/").slice(0, -1).join("/");
		parentFolder = parentFolder
			.replace(/\/Users\/\w+\/Library\/Mobile Documents\/com~apple~CloudDocs/, "☁️")
			.replace(/\/Users\/\w+/, "~");

		return {
			title: fileName + " " + $.getenv("tag_emoji"),
			subtitle: parentFolder,
			icon: extensionToAlfredIcon(path),
			match: alfredMatcher(fileName),
			type: "file:skipcheck",
			uid: path,
			arg: path,
		};
	});

	return JSON.stringify({ items: taggedFiles });
}
