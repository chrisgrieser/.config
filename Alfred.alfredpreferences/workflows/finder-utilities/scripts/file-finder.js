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

const shellCmds = {
	// INFO `fd` does not allow to sort results by recency, thus using `rg` instead
	// CAVEAT however, as opposed to `fd`, `rg` does not give us folders.
	[$.getenv("recent_keyword")]: {
		cmd: `cd "$HOME" && rg --no-config --files --sortr=modified --glob="!/Library/" --glob="!*.photoslibrary" || true`,
		pathOutput: "relative",
	},
	[$.getenv("downloads_keyword")]: {
		cmd: `ls -t "${$.getenv("downloads_folder")}"`,
		pathOutput: "relative",
	},
	[$.getenv("trash_keyword")]: {
		cmd: 'find "$HOME/.Trash" "$HOME/Library/Mobile Documents/.Trash" -depth 1',
		pathOutput: "absolute",
	},
	[$.getenv("tag_keyword")]: {
		cmd: `mdfind "kMDItemUserTags == ${$.getenv("tag_to_search")}"`,
		pathOutput: "absolute",
	},
	[$.getenv("frontwin_keyword")]: {
		cmd: (function name() {
			return 1;
		})(),
		pathOutput: "relative",
	},
};

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// `alfred_workflow_keyword` is not set when triggered via hotkey
	const keyword =
		$.NSProcessInfo.processInfo.environment.objectForKey("alfred_workflow_keyword").js ||
		$.NSProcessInfo.processInfo.environment.objectForKey("keyword_from_hotkey").js;
	const shellCmd = shellCmds[keyword];
	const isTagSearch = keyword === $.getenv("tag_keyword");

	// GUARD duplicated keywords
	if (hasDuplicateKeywords()) {
		return errorItem(
			"⚠️ Duplicate keywords",
			"In the workflow configuration, use only unique keywords.",
		);
	}
	if (keyword === $.getenv("frontwin_keyword")) {
		return errorItem("⚠️ No Finder window open.");
	}

	// DETERMINE SHELL COMMAND
	if (shellCmd) {
		const rgCmd = `cd "$HOME" && rg --no-config --files --follow --sortr=modified --glob='!/Library/' --glob='!*.photoslibrary' || true`;
		shellCmd = `cd '${shellCmd}' && ${rgCmd}`;
	} else {
		shellCmd = `mdfind "kMDItemUserTags == ${$.getenv("tag_to_search")}"`; // https://www.alfredforum.com/topic/18041-advanced-search-using-tags-%C3%A0-la-finder/
		if (!isTagSearch) {
			const home = app.pathTo("home folder");
			const normalTrash = home + "/.Trash";
			const iCloudTrash = home + "/Library/Mobile Documents/.Trash";
			shellCmd = `find "$HOME/.Trash" "$HOME/Library/Mobile Documents/.Trash" -maxdepth 1 -mindepth 1`;
		}
	}
	const stdout = app.doShellScript(shellCmd).trim();

	// GUARD no file found
	if (stdout === "") {
		const foldername = shellCmd
			? "in " + shellCmd.split("/").pop()
			: isTagSearch
				? `tagged with "${$.getenv("tag_to_search")}"`
				: "in Trash";
		return JSON.stringify({ items: [{ title: `No file found ${foldername}.`, valid: false }] });
	}
	// GUARD no front window
	if (keyword === $.getenv("frontwin_keyword") && stdout === "ls: : No such file or directory") {
		return JSON.stringify({ items: [{ title: "⚠️ No front window found", valid: false }] });
	}

	// CREATE ALFRED ITEMS
	const alfredItems = stdout.split("\r").map((path) => {
		const name = path.split("/").pop() || "";
		let parent = path.includes("/") ? "/" + path.split("/").slice(0, -2).join("/") : "";
		if (!shellCmd) {
			parent = isTagSearch
				? parent.replace(/.*\/com~apple~CloudDocs/, "☁️").replace(/\/\/Users\/\w+/, "~")
				: "";
		}
		const absPath = shellCmd ? shellCmd + "/" + path : path;
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

	// INFO do not use Alfred's caching mechanism, since it does not work with
	// `alfred_workflow_keyword` https://www.alfredforum.com/topic/21754-wrong-alfred-55-cache-used-when-using-alternate-keywords-like-foobar/#comment-113358
	return JSON.stringify({ items: alfredItems });
}
