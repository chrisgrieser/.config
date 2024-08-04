#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_#()[\].:;,'"`]/g, " ");
	return [clean, str].join(" ") + " ";
}

/** @param {string} path */
function extensionToAlfredIcon(path) {
	const ext = path.split(".").pop() || "";
	const imageExtensions = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic"];
	return imageExtensions.includes(ext) ? { path: path } : { path: path, type: "fileicon" };
}

/** @return {string} path of the front Finder window, or `""` if there is no Finder window */
function getFrontWin() {
	try {
		const path = Application("Finder").insertionLocation().url().slice(7, -1);
		return decodeURIComponent(path);
	} catch (_error) {
		return "";
	}
}

/** Necessary, as this workflow requires unique keywords to determine which kind
 * of search to perform.
 * @return {boolean} whether there are duplicates
 * */
function hasDuplicateKeywords() {
	const keywords = [
		$.getenv("downloads_keyword"),
		$.getenv("recent_keyword"),
		$.getenv("frontwin_keyword"),
		$.getenv("tag_keyword"),
		$.getenv("trash_keyword"),
	];
	const uniqueKeywords = [...new Set(keywords)];
	return uniqueKeywords.length !== keywords.length;
}

/**
 * @param {string} title
 * @param {string=} subtitle
 */
function errorItem(title, subtitle) {
	return JSON.stringify({
		items: [{ title: title, subtitle: subtitle || "", valid: false }],
	});
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {Record<string, {parent?: string|Function; cmd: string; outputType: "absolute" | "relative" | "name"}>} */
const shellCmds = {
	[$.getenv("recent_keyword")]: {
		// INFO `fd` does not allow to sort results by recency, thus using `rg` instead
		// CAVEAT however, as opposed to `fd`, `rg` does not give us folders.
		cmd: 'cd "$HOME" && rg --no-config --files --sortr=modified --glob="!/Library/" --glob="!*.photoslibrary" || true',
		outputType: "relative",
		parent: app.pathTo("home folder"),
	},
	[$.getenv("downloads_keyword")]: {
		cmd: `ls -t "${$.getenv("downloads_folder")}"`,
		outputType: "name",
		parent: $.getenv("downloads_folder"),
	},
	[$.getenv("trash_keyword")]: {
		cmd: 'find "$HOME/.Trash" "$HOME/Library/Mobile Documents/.Trash" -depth 1',
		outputType: "absolute",
	},
	[$.getenv("tag_keyword")]: {
		cmd: `mdfind "kMDItemUserTags == ${$.getenv("tag_to_search")}"`,
		outputType: "absolute",
	},
	[$.getenv("frontwin_keyword")]: {
		cmd: 'ls -t1 "%s"',
		outputType: "name",
	},
};

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// DETERMINE KEYWORD
	if (hasDuplicateKeywords()) {
		return errorItem(
			"⚠️ Duplicate keywords",
			"In the workflow configuration, use only unique keywords.",
		);
	}
	const keyword = // `alfred_workflow_keyword` is not set when triggered via hotkey
		$.NSProcessInfo.processInfo.environment.objectForKey("alfred_workflow_keyword").js ||
		$.NSProcessInfo.processInfo.environment.objectForKey("keyword_from_hotkey").js;

	// EXECUTE SEARCH
	let { cmd, outputType, parent } = shellCmds[keyword];
	if (keyword === $.getenv("frontwin_keyword")) {
		parent = getFrontWin();
		if (parent === "") return errorItem("⚠️ No Finder window found.");
		cmd = cmd.replace("%s", parent);
	}
	const stdout = app.doShellScript(cmd).trim();
	if (stdout === "") return errorItem("No file found.");

	// CREATE ALFRED ITEMS
	const results = stdout.split("\r").map((line) => {
		const name = outputType === "name" ? line : line.split("/").pop() || "";
		let parent = line.includes("/") ? "/" + line.split("/").slice(0, -2).join("/") : "";
		const absPath = outputType === "absolute" ? line : parent + "/" + name;
		const emoji = keyword === $.getenv("tag_keyword") ? $.getenv("tag_emoji") : "";

		return {
			title: name + emoji,
			subtitle: parent,
			arg: absPath,
			type: "file:skipcheck",
			match: alfredMatcher(name),
			icon: extensionToAlfredIcon(absPath),
		};
	});

	// INFO do not use Alfred's caching mechanism, since it does not work with
	// `alfred_workflow_keyword` https://www.alfredforum.com/topic/21754-wrong-alfred-55-cache-used-when-using-alternate-keywords-like-foobar/#comment-113358
	return JSON.stringify({ items: results });
}
