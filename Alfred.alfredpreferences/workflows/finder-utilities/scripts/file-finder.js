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

//──────────────────────────────────────────────────────────────────────────────

/** @type {Record<string, {cmd: string; dir?: string; absPathOutput?: boolean;}>} */
const shellCmds = {
	[$.getenv("recent_keyword")]: {
		// INFO `fd` does not allow to sort results by recency, thus using `rg` instead
		// CAVEAT however, as opposed to `fd`, `rg` does not give us folders.
		cmd: 'cd "$HOME" && rg --no-config --files --sortr=modified --glob="!/Library/" --glob="!*.photoslibrary" || true',
		dir: app.pathTo("home folder"),
	},
	[$.getenv("downloads_keyword")]: {
		cmd: `ls -t "${$.getenv("downloads_folder")}"`,
		dir: $.getenv("downloads_folder"),
	},
	[$.getenv("trash_keyword")]: {
		cmd: 'find "$HOME/.Trash" "$HOME/Library/Mobile Documents/.Trash" -depth 1',
		absPathOutput: true,
	},
	[$.getenv("tag_keyword")]: {
		cmd: `mdfind "kMDItemUserTags == ${$.getenv("tag_to_search")}"`,
		absPathOutput: true,
	},
	[$.getenv("frontwin_keyword")]: {
		cmd: 'ls -t1 "%s"',
	},
};

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// DETERMINE KEYWORD
	if (hasDuplicateKeywords()) {
		return JSON.stringify({
			items: [{ title: "Duplicate keywords in workflow configuration", valid: false }],
		});
	}
	const keyword = // `alfred_workflow_keyword` is not set when triggered via hotkey
		$.NSProcessInfo.processInfo.environment.objectForKey("alfred_workflow_keyword").js ||
		$.NSProcessInfo.processInfo.environment.objectForKey("keyword_from_hotkey").js;

	// EXECUTE SEARCH
	let { cmd, dir, absPathOutput } = shellCmds[keyword];
	if (keyword === $.getenv("frontwin_keyword")) {
		dir = getFrontWin();
		if (dir === "") {
			return JSON.stringify({ items: [{ title: "⚠️ No Finder window found.", valid: false }] });
		}
		cmd = cmd.replace("%s", dir);
	}
	const stdout = app.doShellScript(cmd).trim();
	if (stdout === "") return JSON.stringify({ items: [{ title: "No file found.", valid: false }] });

	// CREATE ALFRED ITEMS
	const maxFiles = Number.parseInt($.getenv("max_files"));
	const results = stdout
		.split("\r")
		.slice(0, maxFiles) // PERF
		.map((line) => {
			const name = line.split("/").pop() || "";
			const absPath = absPathOutput ? line : dir + "/" + line;

			const parent = absPath.split("/").slice(0, -1).join("/");
			const subtitle = parent.replace(/.*\/com~apple~CloudDocs/, "☁️").replace(/\/Users\/\w+/, "~");

			const ext = name.split(".").pop() || "";
			const imageExt = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic"];
			const icon = imageExt.includes(ext) ? { path: absPath } : { path: absPath, type: "fileicon" };
			const emoji = keyword === $.getenv("tag_keyword") ? $.getenv("tag_emoji") : "";

			return {
				title: name + emoji,
				subtitle: subtitle,
				arg: absPath,
				type: "file:skipcheck",
				match: alfredMatcher(name),
				icon: icon,
			};
		});

	// INFO do not use Alfred's caching mechanism, since it does not work with
	// `alfred_workflow_keyword` https://www.alfredforum.com/topic/21754-wrong-alfred-55-cache-used-when-using-alternate-keywords-like-foobar/#comment-113358
	return JSON.stringify({ items: results });
}
