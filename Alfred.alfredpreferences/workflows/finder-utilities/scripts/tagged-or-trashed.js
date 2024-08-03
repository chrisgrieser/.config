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
	// `alfred_workflow_keyword` is not set when triggered via hotkey
	const keyword =
		$.NSProcessInfo.processInfo.environment.objectForKey("alfred_workflow_keyword").js ||
		$.NSProcessInfo.processInfo.environment.objectForKey("keyword_from_hotkey").js;

	const isTrashSearch = keyword === $.getenv("trash_keyword");
	const tagName = $.getenv("tag_to_search");

	let shellCmd = `mdfind "kMDItemUserTags == ${tagName}"`; // https://www.alfredforum.com/topic/18041-advanced-search-using-tags-%C3%A0-la-finder/
	if (isTrashSearch) {
		const home = app.pathTo("home folder");
		const normalTrash = home + "/.Trash";
		const iCloudTrash = home + "/Library/Mobile Documents/.Trash";
		shellCmd = `find "${normalTrash}" "${iCloudTrash}" -maxdepth 1 -mindepth 1`;
	}

	const results = app
		.doShellScript(shellCmd)
		.trim() // remove trailing newline from `doShellScript`
		.split("\r")
		.map((absPath) => {
			const [_, parent, name] = absPath.match(/(.*)\/(.*)/) || [];

			const parentDisplay = isTrashSearch ? "" : parent
				.replace(/\/Users\/\w+\/Library\/Mobile Documents\/com~apple~CloudDocs/, "☁️")
				.replace(/\/Users\/\w+/, "~");
			const emoji = isTrashSearch ? "" : $.getenv("tag_emoji");

			return {
				title: name + emoji,
				subtitle: parentDisplay,
				icon: extensionToAlfredIcon(absPath),
				match: alfredMatcher(name),
				type: "file:skipcheck",
				uid: absPath,
				arg: absPath,
			};
		});

	// GUARD no result found
	if (results.length === 0) {
		const msg = isTrashSearch ? "No trashed files found" : `No files found with tag ${tagName}`;
		return JSON.stringify({ items: [{ title: msg, valid: false }] });
	}

	return JSON.stringify({ items: results });
}
