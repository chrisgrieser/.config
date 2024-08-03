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
		path = Application("Finder").insertionLocation().url().slice(7, -1);
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
	const tagName = $.getenv("tag_to_search");
	const isTagSearch = keyword === $.getenv("tag_keyword");

	if (hasDuplicateKeywords()) {
		return JSON.stringify({ items: [{ title: "", valid: false }], });
	}

	// GUARD no front window
	if (rgFolder === "") {
		return JSON.stringify({ items: [{ title: "No front window found", valid: false }], });
	}

	// DETERMINE SHELL COMMAND
	let shellCmd = "";
	if (rgFolder) {
		const maxDepth = Number.parseInt($.getenv("max_depth"));
		// `fd` does not allow to sort results by recency, thus using `rg` instead
		const rgCmd = `rg --no-config --files --sortr=modified --max-depth=${maxDepth} \
			--glob='!/Library/' --glob='!*.photoslibrary' || true`;
		shellCmd = `cd '${rgFolder}' && ${rgCmd}`;
	} else {
		shellCmd = `mdfind "kMDItemUserTags == ${tagName}"`; // https://www.alfredforum.com/topic/18041-advanced-search-using-tags-%C3%A0-la-finder/
		if (!isTagSearch) {
			const home = app.pathTo("home folder");
			const normalTrash = home + "/.Trash";
			const iCloudTrash = home + "/Library/Mobile Documents/.Trash";
			shellCmd = `find "${normalTrash}" "${iCloudTrash}" -maxdepth 1 -mindepth 1`;
		}
	}
	const stdout = app.doShellScript(shellCmd).trim();

	// GUARD no result found
	if (stdout === "") {
		const foldername = rgFolder
			? "in " + rgFolder.split("/").pop()
			: isTagSearch
				? "tagged with " + tagName
				: "in Trash";
		return JSON.stringify({
			items: [{ title: `No file found ${foldername}`, valid: false }],
		});
	}

	// CREATE ALFRED ITEMS
	const alfredItems = stdout.split("\r").map((path) => {
		const name = path.split("/").pop() || "";
		let parent = path.includes("/") ? "/" + path.split("/").slice(0, -2).join("/") : "";
		if (!rgFolder) {
			parent = isTagSearch
				? parent.replace(/.*\/com~apple~CloudDocs/, "☁️").replace(/\/\/Users\/\w+/, "~")
				: "";
		}
		const absPath = rgFolder ? rgFolder + "/" + path : path;
		const emoji = isTagSearch ? $.getenv("tag_emoji") : "";

		return {
			title: name + emoji,
			subtitle: parent,
			arg: absPath,
			type: "file:skipcheck",
			match: alfredMatcher(name),
			icon: extensionToAlfredIcon(absPath),
		};
	});

	return JSON.stringify({ items: alfredItems });
}
