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

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: okay here
function run() {
	const aliasMaxLen = Number.parseInt($.getenv("alias_max_length"));
	const vaultPath = $.getenv("vault_path");

	// aliases
	const metadataExtrFile = vaultPath + "/.obsidian/plugins/metadata-extractor/metadata.json";
	const metadata = fileExists(metadataExtrFile) ? JSON.parse(readFile(metadataExtrFile)) : [];
	/** @type {Record<string, string[]>} */
	const aliasMap = {};
	for (const item of metadata) {
		aliasMap[item.relativePath] = item.aliases;
	}

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

	// determine files to be listed
	const vaultConfig = vaultPath + "/.obsidian/app.json";
	const ignoredDirs = fileExists(vaultConfig)
		? JSON.parse(readFile(vaultConfig)).userIgnoreFilters
		: [];
	// PERF `find` quicker than `mdfind`
	let cmd = `cd "${vaultPath}" && find . \\( -name "*.md" -or -name "*.canvas" \\) -not -path "./.trash/*"`;
	for (const dir of ignoredDirs) {
		if (dir.startsWith("/") && dir.endsWith("/")) cmd += ` -not -regex "*${dir.slice(1, -1)}*/*"`;
		else if (dir.endsWith("/")) cmd += ` -not -path "./${dir}*"`;
	}
	const filesInVault = app.doShellScript(cmd).split("\r");

	/** @type {AlfredItem[]} */
	const results = [];
	for (let relPath of filesInVault) {
		relPath = relPath.slice(2); // remove `./`
		const parts = relPath.split("/");
		const name = parts.pop() || "";
		const parent = parts.join("/");
		const absPath = vaultPath + "/" + relPath;

		// subtitle & matcher
		const aliases = aliasMap[relPath] || [];
		const shortAliases =
			aliases.length < 2
				? aliases
				: aliases.map((a) => (a.length > aliasMaxLen ? a.slice(0, aliasMaxLen) + "…" : a));
		let matcher = alfredMatcher(name) + alfredMatcher(aliases.join(" "));
		const subtitle =
			"▸ " + parent + (aliases.length > 0 ? "   ■   " + shortAliases.join(", ") : "");

		// recent & bookmarked files
		let icon = "";
		if (bookmarks.includes(relPath)) {
			icon += "🔖 ";
			matcher += " bookmarks"
		}
		if (recentItems.includes(relPath)) {
			icon += "🕑 ";
			matcher += " recent"
		}

		/** @type {AlfredItem} */
		const alfredItem = {
			title: icon + name,
			subtitle: subtitle,
			arg: absPath,
			uid: absPath,
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
