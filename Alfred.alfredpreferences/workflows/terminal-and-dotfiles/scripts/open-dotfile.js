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

/**
 * @param {string} ext
 * @return {string} iconPath
 */
function downloadImageOrGetCached(ext) {
	// biome-ignore-start lint/style/useNamingConvention: filename, not set by me
	/** @type {Record<string, string>} */
	const extToFiletype = {
		add: "vim", // vim spellfile
		adblock: "taskfile", // :/
		bib: "bibliography",
		conf: "settings",
		csl: "citation",
		csv: "database",
		docx: "word",
		gitignore: "settings",
		ignore: "settings",
		js: "javascript",
		jsonc: "json",
		md: "markdown",
		mjs: "javascript",
		pptx: "powerpoint",
		py: "python",
		scm: "scheme",
		sh: "powershell",
		ts: "typescript",
		txt: "taskfile", // :/
		webloc: "url",
		xlsx: "excel",
		yaml: "yaml",
		yml: "yaml",
		zprofile: "powershell",
		zsh: "powershell",
		zshenv: "powershell",
		zshrc: "powershell",
	};
	// biome-ignore-end lint/style/useNamingConvention: _
	const filetype = extToFiletype[ext] || ext;

	const localPath = $.getenv("alfred_workflow_cache") + "/" + filetype + ".svg";
	if (!fileExists(localPath)) {
		console.log("Downloading icon for " + ext);
		const url = `https://raw.githubusercontent.com/material-extensions/vscode-material-icon-theme/refs/heads/main/icons/${filetype}.svg`;
		app.doShellScript(`curl --silent '${url}' > '${localPath}'`);
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

		// extension icon
		let ext = "";
		if (name.includes(".")) ext = name.split(".").pop() || "";
		if (name === "Justfile") ext = "just";
		if (name === "Brewfile") ext = "config";

		/** @type {{type: "" | "fileicon"; path: string}} */
		const iconObj = { type: "", path: "" };
		const isImageFile = ["png", "icns", "webp", "tiff", "gif", "jpg", "jpeg"].includes(ext);
		if (isImageFile) iconObj.type = "fileicon";
		if (!ext) iconObj.path = "./fallback-icons/default.svg";
		if (ext && !isImageFile) iconObj.path = downloadImageOrGetCached(ext);

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
