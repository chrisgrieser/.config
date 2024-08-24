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
function run() {
	const vaultPath = $.getenv("vault_path");
	const maxLen = Number.parseInt($.getenv("alias_max_length"));

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

	// PERF `find` quicker than `mdfind`
	const shellCmd = `find "${vaultPath}" \\( -name "*.md" -or -name "*.canvas" \\) -not -path "*/.trash/*"`;

	const results = []
	const filesInVault =app.doShellScript(shellCmd).split("\r")
	for (const absPath of filesInVault) {
			const relPath = absPath.slice(vaultPath.length + 1);
			const parts = relPath.split("/");
			const name = parts.pop() || "";
			const obsidianUri = "obsidian://open?path=" + encodeURIComponent(absPath);

			// subtitle & matcher
			const parent = "▸ " + parts.join("/");
			const aliases = aliasMap[relPath] || [];
			const shortAliases = aliases.map((a) => (a.length > maxLen ? a.slice(0, maxLen) + "…" : a));
			const matcher = alfredMatcher(name) + alfredMatcher(aliases.join(" "));
			let subtitle = parent;
			if (aliases.length > 0) subtitle += "   ■   " + shortAliases.join(", ");

			// recent files
			const icon = recentItems.includes(relPath) ? "🕑 " : "";
			const mode = recentItems.includes(relPath) ? "unshift" : "push";

			const alfredItem = {
				title: icon + name,
				subtitle: subtitle,
				arg: absPath,
				uid: absPath,
				variables: { uri: obsidianUri },
				quicklookurl: absPath,
				type: "file:skipcheck",
				match: matcher,
				icon: { path: absPath, type: "fileicon" },
			};
			results[mode](alfredItem);
		};

	return JSON.stringify({
		items: results,
		cache: { seconds: 600, loosereload: true },
	});
}
