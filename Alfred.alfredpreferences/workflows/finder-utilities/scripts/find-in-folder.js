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

/** @return {string} */
function getFrontWin() {
	let path;
	try {
		path = Application("Finder").insertionLocation().url().slice(7);
	} catch (_error) {
		return "";
	}
	return decodeURIComponent(path);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {Record<string, string>} */
const rgLocations = {
	[$.getenv("downloads_keyword")]: $.getenv("downloads_folder"),
	[$.getenv("recent_keyword")]: app.pathTo("home folder"),
	[$.getenv("frontwin_keyword")]: getFrontWin(),
};

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// `alfred_workflow_keyword` is not set when triggered via hotkey
	const keyword =
		$.NSProcessInfo.processInfo.environment.objectForKey("alfred_workflow_keyword").js ||
		$.NSProcessInfo.processInfo.environment.objectForKey("keyword_from_hotkey").js;
	const rgFolder = rgLocations[keyword];

	// GUARD no front window
	if (rgFolder === "") {
		return JSON.stringify({
			items: [{ title: "No front window found", valid: false }],
		});
	}

	const maxDepth = Number.parseInt($.getenv("max_depth"));
	// `fd` does not allow to sort results by recency, thus using `rg` instead
	const rgCmd = `rg --no-config --files --sortr=modified --max-depth=${maxDepth} \
		--glob='!/Library/' --glob='!*.photoslibrary' || true`;

	const results = app
		.doShellScript(`cd '${rgFolder}' && ${rgCmd}`)
		.trim() // remove trailing newline from `doShellScript`
		.split("\r")
		.map((relPath) => {
			const name = relPath.split("/").pop() || "";
			const parent = relPath.includes("/") ? "/" + relPath.split("/").slice(0, -2).join("/") : "";
			const absPath = rgFolder + "/" + relPath;

			return {
				title: name,
				subtitle: parent,
				arg: absPath,
				type: "file:skipcheck",
				match: alfredMatcher(name),
				icon: extensionToAlfredIcon(absPath),
			};
		});

	// GUARD no result found
	if (results.length === 0) {
		const foldername = rgFolder.split("/").pop();
		return JSON.stringify({
			items: [{ title: `No file found in "${foldername}"`, valid: false }],
		});
	}

	return JSON.stringify({ items: results });
}
