#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_()[/\]]/g, " ");
	return [clean, str].join(" ");
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
	const superIconFile = $.getenv("supercharged_icon_file");

	// aliases & tags via Metadata Extractor
	const metadataExtrFile = vaultPath + "/.obsidian/plugins/metadata-extractor/metadata.json";
	const metadataObj = fileExists(metadataExtrFile) ? JSON.parse(readFile(metadataExtrFile)) : [];
	/** @type {Record<string, {aliases: string[], tags: string[]}>} */
	const metadata = {};
	for (const item of metadataObj) {
		metadata[item.relativePath] = { aliases: item.aliases, tags: item.tags };
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

	// supercharged icons
	/** @type {{tag: string, icon: string}[]} */
	const iconTags = [];
	/** @type {{folder: string, icon: string}[]} */
	const iconFolders = [];
	if (superIconFile && fileExists(superIconFile)) {
		const superIcons = readFile(superIconFile)
			.split("\n")
			.filter((line) => line.trim().length > 0);
		for (const line of superIcons) {
			const [cond, icon] = line.split(",").map((s) => s.trim());
			if (cond.startsWith("/")) {
				// slice leading /
				iconFolders.push({ folder: cond.slice(1), icon: icon });
			} else if (cond.startsWith("#")) {
				// slice leading #
				iconTags.push({ tag: cond.slice(1), icon: icon });
			}
		}
	}

	// determine files to be listed
	const vaultConfig = vaultPath + "/.obsidian/app.json";
	const ignoredDirs = fileExists(vaultConfig)
		? JSON.parse(readFile(vaultConfig)).userIgnoreFilters
		: [];
	// PERF `find` quicker than `mdfind`
	let cmd = `cd "${vaultPath}" && find . \\( -name "*.md" -or -name "*.canvas" \\) -not -path "./.trash/*"`;
	for (const dir of ignoredDirs) {
		if (dir.startsWith("/"))
			cmd += ` -not -regex "*${dir.slice(1, -1)}*/*"`; // regex
		else if (dir.endsWith("/"))
			cmd += ` -not -path "./${dir}*"`; // dir
		else cmd += ` -not -path "./${dir}"`; // file
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
			const name = parts.pop() || "";
			const parent = parts.join("/");
			const absPath = vaultPath + "/" + relPath;

			// subtitle & matcher
			const aliases = metadata[relPath]?.aliases || [];
			const shortAliases =
				aliases.length < 2
					? aliases
					: aliases.map((a) => (a.length > aliasMaxLen ? a.slice(0, aliasMaxLen) + "…" : a));
			const subtitle =
				"▸ " + parent + (aliases.length > 0 ? "   ■   " + shortAliases.join(", ") : "");

			// icons
			let icons = "";
			if (bookmarks.includes(relPath)) icons += "🔖 ";
			if (recentItems.includes(relPath)) icons += "🕑 ";
			const tags = metadata[relPath]?.tags || [];
			for (const tag of tags) {
				const tagIcon = iconTags.find((i) => i.tag === tag)?.icon;
				if (tagIcon) icons += tagIcon + " ";
			}
			for (const iconFolder of iconFolders) {
				if (parent.startsWith(iconFolder.folder)) icons += iconFolder.icon + " ";
			}

			// matcher
			const matcher = [
				alfredMatcher(name),
				alfredMatcher(aliases.join(" ")),
				alfredMatcher(tags.map((t) => "#" + t).join(" ")),
			];

			/** @type {AlfredItem} */
			const alfredItem = {
				title: icons + name,
				subtitle: subtitle,
				arg: absPath,
				uid: absPath,
				type: "file:skipcheck",
				match: matcher.join(" "),
				icon: { path: absPath, type: "fileicon" },
			};

			const insertWhere = recentItems.includes(relPath) ? "unshift" : "push";
			acc[insertWhere](alfredItem);
			return acc;
		}, []);

	// OUTPUT
	return JSON.stringify({
		items: filesInVault,
		cache: { seconds: 600, loosereload: true },
	});
}
