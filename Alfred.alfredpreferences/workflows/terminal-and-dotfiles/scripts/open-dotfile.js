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

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: alfred run
function run() {
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

		// TYPE-ICON
		// SOURCE
		// 1. https://github.com/material-extensions/vscode-material-icon-theme/tree/main/icons
		// 2. https://github.com/vscode-icons/vscode-icons/tree/master/icons
		let type = "";
		if (name.includes(".")) type = name.split(".").pop() || "";
		else if (name === "Justfile" || name === "Brewfile") type = name;
		else type = "default";

		/** @type {{type: "" | "fileicon"; path: string}} */
		const iconObj = { type: "", path: "" };
		const isImageFile = ["png", "icns", "webp", "tiff", "gif", "jpg", "jpeg"].includes(type);
		iconObj.path = isImageFile ? absPath : `./filetype-icons/${type}.svg`;

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
