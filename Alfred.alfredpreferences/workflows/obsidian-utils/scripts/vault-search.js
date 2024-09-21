#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_()[\]]/g, " ");
	return [clean, str].join(" ") + " ";
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

/**
 * @param {string} thePath
 * @param {string[]} candidates
 * @return {boolean}
 */
function pathMatchesAnyFrom(thePath, candidates) {
	for (const thisCandidate of candidates) {
		if (thePath.includes(thisCandidate)) return true;
	}
	return false;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const maxLen = Number.parseInt($.getenv("alias_max_length"));
	const vaultPath = $.getenv("vault_path");

	// aliases
	const metadataExtrFile = vaultPath + "/.obsidian/plugins/metadata-extractor/metadata.json";
	const metadata = fileExists(metadataExtrFile) ? JSON.parse(readFile(metadataExtrFile)) : [];
	/** @type {Record<string, string[]>} */
	const aliasMap = {};
	for (const item of metadata) {
		aliasMap[item.relativePath] = item.aliases;
	}

	// ignored
	const vaultConfig = vaultPath + "/.obsidian/app.json";
	const ignoredDirs = fileExists(vaultConfig)
		? JSON.parse(readFile(vaultConfig)).userIgnoreFilters
		: [];

	// recent
	const recentItemsFile = vaultPath + "/.obsidian/workspace.json";
	const recentItems = fileExists(recentItemsFile)
		? JSON.parse(readFile(recentItemsFile)).lastOpenFiles.slice(0, 10)
		: [];

	// bookmarks
	const bookmarkFile = vaultPath + "/.obsidian/bookmarks.json";
	const bookmarks = fileExists(bookmarkFile)
		? JSON.parse(readFile(bookmarkFile)).items.map((/** @type {{ path: string; }} */ b) => b.path)
		: [];

	// PERF `find` quicker than `mdfind`
	const shellCmd = `find "${vaultPath}" \\( -name "*.md" -or -name "*.canvas" \\) -not -path "*/.trash/*"`;

	/** @type {AlfredItem[]} */
	const results = [];
	const filesInVault = app.doShellScript(shellCmd).split("\r");

	for (const absPath of filesInVault) {
		const relPath = absPath.slice(vaultPath.length + 1);
		const parts = relPath.split("/");
		const name = parts.pop() || "";
		const parent = parts.join("/");

		// skip if ignored (items in Obsidian list end with `/`)
		if (pathMatchesAnyFrom(parent + "/", ignoredDirs)) continue;

		// subtitle & matcher
		const aliases = aliasMap[relPath] || [];
		const shortAliases = aliases.map((a) => (a.length > maxLen ? a.slice(0, maxLen) + "…" : a));
		const matcher = alfredMatcher(name) + alfredMatcher(aliases.join(" "));
		const subtitle =
			"▸ " + parent + (aliases.length > 0 ? "   ■   " + shortAliases.join(", ") : "");

		// recent & bookmarked files
		let icon = "";
		if (bookmarks.includes(relPath)) icon += "🔖 ";
		if (recentItems.includes(relPath)) icon += "🕑 ";

		/** @type {AlfredItem} */
		const alfredItem = {
			title: icon + name,
			subtitle: subtitle,
			arg: absPath,
			uid: absPath,
			variables: { uri: "obsidian://open?path=" + encodeURIComponent(absPath) },
			quicklookurl: absPath,
			type: "file:skipcheck",
			match: matcher,
			icon: { path: absPath, type: "fileicon" },
		};

		const insertWhere = recentItems.includes(relPath) ? "unshift" : "push";
		results[insertWhere](alfredItem);
	}

	// OUTPUT
	return JSON.stringify({
		items: results,
		cache: { seconds: 600, loosereload: true },
	});
}
