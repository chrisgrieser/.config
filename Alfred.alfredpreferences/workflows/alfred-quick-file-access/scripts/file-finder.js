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

/** @return {string} path of front Finder window; `""` if there is no Finder window */
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
		$.getenv("custom_folder_keyword"),
		$.getenv("recent_keyword"),
		$.getenv("frontwin_keyword"),
		$.getenv("tag_keyword"),
		$.getenv("trash_keyword"),
	];
	const uniqueKeywords = [...new Set(keywords)];
	return uniqueKeywords.length !== keywords.length;
}

/** @param {string} msg */
function errorItem(msg) {
	return JSON.stringify({ items: [{ title: msg, valid: false }] });
}

/** @return {string} path */
function getTrashPathQuoted() {
	const macosVersion = Number.parseFloat(app.systemInfo().systemVersion);
	let trashLocation = "$HOME/Library/Mobile Documents/";

	// location dependent on macOS version: https://github.com/chrisgrieser/alfred-quick-file-access/issues/4
	if (macosVersion < 15) trashLocation += "com~apple~CloudDocs/";
	const trashPath = trashLocation + ".Trash";

	// Checking via `Application("Finder").exists()` sometimes has permission
	// issues because the path is in iCloud. Thus checking via `test -d` instead.
	const userHasIcloudDrive = app.doShellScript(`test -d "${trashPath}" || echo "no"`) !== "no";

	if (userHasIcloudDrive) return `"${trashPath}"`;

	return "";
}

//──────────────────────────────────────────────────────────────────────────────

const rgIgnoreFile =
	$.getenv("alfred_preferences") +
	"/workflows/" +
	$.getenv("alfred_workflow_uid") +
	"/scripts/home-icloud-ignore-file";

// FIX for external CLIs not being recognized on older Macs
const pathExport = "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; ";

/** @typedef {Object} SearchConfig
 * @property {string} shellCmd `%s` is replaced with `dir`
 * @property {boolean=} shallowOutput whether the `shellCmd` performs a search of depth 1
 * @property {boolean=} absPathOutput whether the `shellCmd` gives absolute paths as output
 * @property {string=} directory where to search
 * @property {number=} maxFiles if not set, all files are returned
 * @property {string=} prefix solely for display purposes
 */

/** @type {Record<string, SearchConfig>} */
const searchConfig = {
	[$.getenv("recent_keyword")]: {
		// INFO `fd` does not allow to sort results by recency, thus using `rg` instead
		// CAVEAT As opposed to `fd`, `rg` does not give us folders, which is
		// acceptable since this searches for recent files, and modification dates
		// for folders are unintuitive (only affected by files one level deep).
		shellCmd:
			pathExport +
			`cd "%s" && rg --no-config --files --binary --sortr=modified --ignore-file="${rgIgnoreFile}"`,
		directory: app.pathTo("home folder"),
		maxFiles: Number.parseInt($.getenv("max_recent_files")),
	},
	[$.getenv("custom_folder_keyword")]: {
		shellCmd: `ls -t "%s"`,
		directory: $.getenv("custom_folder"),
		shallowOutput: true,
	},
	[$.getenv("trash_keyword")]: {
		// - `-maxdepth 1 -mindepth 1` is faster than `-depth 1` PERF
		// - not using `rg`, since it will not find folders
		shellCmd: `find "$HOME/.Trash" ${getTrashPathQuoted()} -maxdepth 1 -mindepth 1`,
		absPathOutput: true,
		shallowOutput: true,
	},
	[$.getenv("tag_keyword")]: {
		shellCmd: `mdfind "kMDItemUserTags == ${$.getenv("tag_to_search")}"`,
		absPathOutput: true,
		prefix: $.getenv("tag_prefix"),
	},
	[$.getenv("frontwin_keyword")]: {
		shellCmd: `ls -t "%s"`,
		directory: "%s", // inserted on runtime
		shallowOutput: true,
	},
};

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// DETERMINE KEYWORD
	if (hasDuplicateKeywords()) return errorItem("⚠️ Duplicate keywords in workflow configuration.");
	const keyword = // `alfred_workflow_keyword` is not set when triggered via hotkey
		$.NSProcessInfo.processInfo.environment.objectForKey("alfred_workflow_keyword").js ||
		$.NSProcessInfo.processInfo.environment.objectForKey("keyword_from_hotkey").js;
	console.log("KEYWORD:", keyword);

	// PARAMETERS
	let { shellCmd, directory, absPathOutput, shallowOutput, maxFiles, prefix } =
		searchConfig[keyword];
	prefix = prefix ? prefix + " " : "";

	// EXECUTE SEARCH
	if (keyword === $.getenv("frontwin_keyword")) {
		directory = getFrontWin();
		if (directory === "") return errorItem("⚠️ No Finder window found.");
	}
	if (directory) shellCmd = shellCmd.replace("%s", directory);
	console.log("SHELL COMMAND\n" + shellCmd);
	const stdout = app.doShellScript(shellCmd).trim();
	console.log("\nSTDOUT (shortened)\n" + stdout.slice(0, 300));
	if (stdout === "") return errorItem("No files found.");

	// CREATE ALFRED ITEMS
	const results = stdout
		.split("\r")
		.slice(0, maxFiles)
		.map((line) => {
			const parts = line.split("/");
			const name = parts.pop() || "";
			const absPath = absPathOutput ? line : directory + "/" + line;

			let subtitle = "";
			if (!shallowOutput) {
				const parent = parts.join("/");
				subtitle = parent.replace(/.*\/com~apple~CloudDocs/, "☁").replace(/\/Users\/\w+/, "~");
				subtitle = "▸ " + subtitle;
			}

			const ext = name.split(".").pop() || "";
			const imageExt = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic"];
			const icon = imageExt.includes(ext)
				? { path: absPath }
				: { path: absPath, type: "fileicon" };

			return {
				title: prefix + name,
				subtitle: subtitle,
				arg: absPath,
				quicklookurl: absPath,
				type: "file:skipcheck",
				match: alfredMatcher(name),
				icon: icon,
			};
		})

	// INFO do not use Alfred's caching mechanism, since it does not work with
	// the `alfred_workflow_keyword` environment variable https://www.alfredforum.com/topic/21754-wrong-alfred-55-cache-used-when-using-alternate-keywords-like-foobar/#comment-113358
	// (Also, it would interfere with the results needing to be live.)
	return JSON.stringify({ items: results });
}
