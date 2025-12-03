#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** Try out all different forms of casings
 * @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-.()_/[\]]/g, " ");
	const squeezed = str.replace(/[-_.]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	const kebabCased = str.replace(/[ _]/g, "-");
	const snakeCased = str.replace(/[ -]/g, "_");
	return [str, clean, squeezed, camelCaseSeparated, kebabCased, snakeCased].join(" ");
}

function ensureCacheFolderExists() {
	const finder = Application("Finder");
	const cacheDir = $.getenv("alfred_workflow_cache");
	if (!finder.exists(Path(cacheDir))) {
		console.log("Cache directory does not exist and is created.");
		const cacheDirBasename = $.getenv("alfred_workflow_bundleid");
		const cacheDirParent = cacheDir.slice(0, -cacheDirBasename.length);
		finder.make({
			new: "folder",
			at: Path(cacheDirParent),
			withProperties: { name: cacheDirBasename },
		});
	}
}

const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

/** @param {string} url @return {string} */
function httpRequest(url) {
	const queryUrl = $.NSURL.URLWithString(url);
	const data = $.NSData.dataWithContentsOfURL(queryUrl);
	return $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
}

/** @param {string} filepath @param {string} text */
function writeToFile(filepath, text) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(filepath, true, $.NSUTF8StringEncoding, null);
}

/**
 * @param {string} ext
 * @return {string} iconPath
 */
function downloadImageOrGetCached(ext) {
	if (ext === "default") return "./fallback-icons/default.svg";

	/** @type {Record<string, string>} */
	const extToFiletype = {
		js: "javascript",
		ts: "typescript",
		py: "python",
		md: "markdown",
		txt: "text",
		yaml: "yaml",
		sh: "shell",
		// biome-ignore lint/style/useNamingConvention: filename, not set by me
		Justfile: "just",
		// biome-ignore lint/style/useNamingConvention: filename, not set by me
		Brewfile: "ruby",
	};
	const filetype = extToFiletype[ext] || ext;

	const localPath = $.getenv("alfred_workflow_cache") + "/" + filetype + ".svg";
	if (!fileExists(localPath)) {
		console.log("Downloading icon for " + ext);
		const url = `https://raw.githubusercontent.com/vscode-icons/vscode-icons/refs/heads/master/icons/file_type_${filetype}.svg`;
		const response = httpRequest(url);
		if (response === "404: Not Found") return "./fallback-icons/default.svg";
		writeToFile(localPath, response);
	}
	return localPath;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: alfred run
function run() {
	ensureCacheFolderExists();
	const dotfilesFolder = $.getenv("dotfiles_folder");

	const modifiedFiles = app
		.doShellScript(`git -C "${dotfilesFolder}" diff --name-only`)
		.split("\r");

	const rgOutput = app
		.doShellScript(
			`PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; \
			rg --no-config --files --hidden --sortr=modified \
			--ignore-file=${dotfilesFolder}/ripgrep/ignore "${dotfilesFolder}"`,
		)
		.split("\r");

	/** @type{AlfredItem|{}[]} */
	const fileArray = rgOutput.map((absPath) => {
		// params
		const name = absPath.split("/").pop() || "ERROR";
		const relPath = absPath.slice(dotfilesFolder.length + 1);
		const relativeParentFolder = relPath.slice(0, -name.length - 1) || "/";
		const matcher = alfredMatcher(`${name} ${relativeParentFolder}`);

		// emoji
		let emoji = "";
		if (relPath.includes("hammerspoon")) emoji += " 🟡";
		else if (relPath.includes("nvim")) emoji += " 🔳";
		if (modifiedFiles.includes(relPath)) emoji += " ✴️";

		// type-icon
		// let type = "";
		// if (name.includes(".")) type = name.split(".").pop() || "";
		// else if (name === "Justfile" || name === "Brewfile") type = name;
		// else type = "blank"; // if no extension
		// if (name.endsWith("-bkp")) type = "backup-file"; // backup-files from `Finder Vim Mode`

		let ext = "";
		if (name.includes(".")) ext = name.split(".").pop() || "default";
		/** @type {{type: "" | "fileicon"; path: string}} */
		const iconObj = { type: "", path: "" };
		const isImageFile = ["png", "icns", "webp", "tiff", "gif", "jpg", "jpeg"].includes(ext);
		iconObj.path = isImageFile ? absPath : downloadImageOrGetCached(ext);

		/** @type {AlfredItem} */
		const item = {
			title: name + emoji,
			match: matcher,
			subtitle: "▸ " + relativeParentFolder,
			icon: iconObj,
			type: "file:skipcheck",
			arg: absPath,
		};
		return item;
	});

	/** @type{AlfredItem|{}[]} */
	const folderArray = app
		.doShellScript(`
			find "${dotfilesFolder}" -type d \
			-not -path "**/.git/*" \
			-not -path "**/*.app/*" \
			-not -path "**/Alfred.alfredpreferences/*" \
			-not -path "**/hammerspoon/Spoons/*"
		`)
		.split("\r")
		.map((/** @type {string} */ absPath) => {
			const name = absPath.split("/").pop();
			if (!name) return {};
			const relPath = absPath.slice(dotfilesFolder.length);
			const relativeParentFolder = relPath.slice(1, -name.length - 1) || "/";

			return {
				title: name,
				subtitle: "▸ " + relativeParentFolder,
				match: alfredMatcher(name) + " folder",
				icon: { type: "fileicon", path: absPath },
				type: "file:skipcheck",
				arg: absPath,
				variables: { filetype: "folder" },
			};
		});

	return JSON.stringify({ items: [...fileArray, ...folderArray] });
}
