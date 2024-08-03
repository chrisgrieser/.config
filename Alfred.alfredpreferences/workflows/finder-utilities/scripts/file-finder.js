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
	const rgCmd = // INFO `fd` does not allow to sort results by recency, thus using `rg` instead
		"rg --no-config --files --sortr=modified --glob='!/Library/' --glob='!*.photoslibrary'";
	const rgFolder = rgLocations[$.getenv("alfred_workflow_keyword")];
	console.log("🖨️ rgFolder:", rgFolder);

	// GUARD no front window
	if (rgFolder === "") {
		return JSON.stringify({
			items: [{ title: "No front window found", valid: false }],
		});
	}

	const results = app
		.doShellScript(`cd '${rgFolder}' && ${rgCmd}`)
		.split("\r")
		.map((relPath) => {
			const [name, ...parent] = relPath.split("/");
			const absPath = rgFolder + "/" + relPath;
			const parentDisplay = (parent || "").slice(0, -1);

			return {
				title: name,
				subtitle: parentDisplay,
				arg: absPath,
				type: "file:skipcheck",
				match: alfredMatcher(name),
				icon: extensionToAlfredIcon(absPath),
			};
		});

	return JSON.stringify({ items: results });
}
