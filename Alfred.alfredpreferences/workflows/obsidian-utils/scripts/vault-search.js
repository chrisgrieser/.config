#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function aMatcher(str) {
	const clean = str.replace(/[-_()[\]/]/g, " ");
	const joined = str.replaceAll(" ", "");
	return [clean, str, joined].join(" ") + " ";
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
	const aliasMaxLen = Number.parseInt($.getenv("alias_max_length"));
	const vaultPath = $.getenv("vault_path");

	// aliases & tags via Metadata Extractor
	const metadataExtrFile = vaultPath + "/.obsidian/plugins/metadata-extractor/metadata.json";
	const metadataObj = fileExists(metadataExtrFile) ? JSON.parse(readFile(metadataExtrFile)) : [];
	/** @type {Record<string, {aliases: string[], tags: string[]}>} */
	const metadata = {};
	for (const item of metadataObj) {
		metadata[item.relativePath] = { aliases: item.aliases, tags: item.tags };
	}

	// recent 10 files
	const recentItemsFile = vaultPath + "/.obsidian/workspace.json";
	const recentItems = fileExists(recentItemsFile)
		? JSON.parse(readFile(recentItemsFile)).lastOpenFiles.slice(0, 10)
		: [];

	// bookmarks
	const bookmarkFile = vaultPath + "/.obsidian/bookmarks.json";
	const bookmarks = fileExists(bookmarkFile)
		? JSON.parse(readFile(bookmarkFile)).items.map((/** @type {{ path: string; }} */ b) => b.path)
		: [];

	// tag icons
	const tagIcons = $.getenv("tag_icons")
		.split("\n")
		.filter((line) => line.includes(","))
		.map((line) => {
			const [tag, icon] = line.split(/ *, */);
			return { tag: tag, icon: icon };
		});

	// folder icons
	const folderIcons = $.getenv("folder_icons")
		.split("\n")
		.filter((line) => line.includes(","))
		.map((line) => {
			const [folder, icon] = line.split(/ *, */);
			return { folder: folder, icon: icon };
		});

	// determine files to be listed
	const vaultConfig = vaultPath + "/.obsidian/app.json";
	const ignoredDirs = fileExists(vaultConfig)
		? JSON.parse(readFile(vaultConfig)).userIgnoreFilters
		: [];
	// PERF `find` quicker than `mdfind`
	let cmd = `cd "${vaultPath}" && find . \\( -name "*.md" -or -name "*.canvas" \\) -not -path "./.trash/*"`;
	for (const dir of ignoredDirs) {
		// 1. regex, 2. folder, 3. file
		if (dir.startsWith("/")) cmd += ` -not -regex "*${dir.slice(1, -1)}*/*"`;
		else if (dir.endsWith("/")) cmd += ` -not -path "./${dir}*"`;
		else cmd += ` -not -path "./${dir}"`;
	}

	//───────────────────────────────────────────────────────────────────────────

	/** @type {AlfredItem[]} */
	const filesInVault = app
		.doShellScript(cmd)
		.split("\r")
		// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: okay here
		.reduce((/** @type {AlfredItem[]} */ acc, relPath) => {
			relPath = relPath.slice(2); // remove `./`
			const parts = relPath.split("/");
			const name = (parts.pop() || "").replace(/\.md$/, ""); // keep `.canvas` extension
			const parent = parts.join("/");
			const absPath = vaultPath + "/" + relPath;

			// subtitle
			const aliases = metadata[relPath]?.aliases || [];
			const shortAliases =
				aliases.length < 2
					? aliases
					: aliases.map((a) => (a.length > aliasMaxLen ? a.slice(0, aliasMaxLen) + "…" : a));
			const subtitle =
				"▸ " + parent + (aliases.length > 0 ? "      ↪ " + shortAliases.join(", ") : "");

			// icons
			let icons = "";
			if (bookmarks.includes(relPath)) icons += "🔖 ";
			if (recentItems.includes(relPath)) icons += "🕑 ";
			const tags = metadata[relPath]?.tags || [];
			for (const tag of tags) {
				const tagIcon = tagIcons.find((i) => i.tag === tag)?.icon;
				if (tagIcon) icons += tagIcon + " ";
			}
			for (const folder of folderIcons) {
				if (parent.startsWith(folder.folder)) icons += folder.icon + " ";
			}

			// matcher
			let matcher = aMatcher(name) + aMatcher(aliases.join(" ")) + " #" + tags.join(" #");
			if (bookmarks.includes(relPath)) matcher += " bookmarks";
			if (recentItems.includes(relPath)) matcher += " recent";

			/** @type {AlfredItem} */
			const alfredItem = {
				title: icons + name,
				subtitle: subtitle,
				arg: absPath,
				uid: absPath,
				type: "file:skipcheck",
				match: matcher,
			};

			const insertWhere = recentItems.includes(relPath) ? "unshift" : "push";
			acc[insertWhere](alfredItem);
			return acc;
		}, []);

	// OUTPUT
	return JSON.stringify({
		items: filesInVault,
		cache: { seconds: 60, loosereload: true },
	});
}
