#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	// try out all the different casings
	const clean = str.replace(/[-()_/[\]]/g, " ");
	const squeezed = str.replace(/[-_]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	const kebabCase = str.replace(/[ _]/g, "-");
	const snakeCase = str.replace(/[ -]/g, "_");
	return [clean, camelCaseSeparated, squeezed, str, kebabCase, snakeCase].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: alfred run
function run() {
	const dotfileFolder = $.getenv("dotfile_folder");
	const dirtyFiles = app.doShellScript(`git -C "${dotfileFolder}" diff --name-only`).split("\r");

	/** @type{AlfredItem|{}[]} */
	const fileArray = app
		.doShellScript(
			`PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; cd "${dotfileFolder}" ;
			fd --type=file --type=symlink --hidden --absolute-path \
			--exclude="**/Alfred.alfredpreferences/workflows/**/*.png"`,
		)
		.split("\r")
		.reverse() // since often used files in `zsh` or `nvim` or further down the alphabet
		.map((absPath) => {
			const name = absPath.split("/").pop();
			if (!name) return {};
			const relPath = absPath.slice(dotfileFolder.length + 1);
			const relativeParentFolder = relPath.slice(0, -name.length - 1) || "/";
			const matcher = alfredMatcher(`${name} ${relativeParentFolder}`);
			const isDirty = dirtyFiles.includes(relPath);

			// emoji
			let emoji = "";
			if (relPath.includes("hammerspoon")) emoji += " 🟡";
			else if (relPath.includes("nvim")) emoji += " 🔳";
			if (isDirty) emoji += " Ⓜ️";

			// type-icon
			let type = "";
			if (name.startsWith(".z")) type = "zsh"; // .zshenv, .zshrc, .zprofile
			else if (name.endsWith("akefile")) type = "make";
			else if (name.startsWith(".")) type = "cfg";
			else if (!name.includes(".")) type = "blank";
			else if (name === "obsidian-vimrc.vim") type = "obsidian";
			else type = name.split(".").pop() || ""; // default: extension

			/** @type {{type: "" | "fileicon"; path: string}} */
			const iconObj = { type: "", path: "" };
			const useFileicon = ["webloc", "url", "ini", "mjs"].includes(type);
			const isImageFile = ["png", "icns"].includes(type);
			if (useFileicon) {
				iconObj.type = "fileicon";
				iconObj.path = absPath;
			} else if (isImageFile) {
				// use image itself
				iconObj.path = absPath;
			} else {
				// use {extension}.png located in icon folder
				iconObj.path = `./custom-filetype-icons/${type}.png`;
			}

			/** @type {AlfredItem} */
			const item = {
				title: name + emoji,
				match: matcher,
				subtitle: "▸ " + relativeParentFolder,
				icon: iconObj,
				type: "file:skipcheck",
				uid: absPath,
				arg: absPath,
			};
			return item;
		});

	/** @type{AlfredItem|{}[]} */
	const folderArray = app
		.doShellScript(
			`PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; cd "${dotfileFolder}" ;
			fd --absolute-path --type=directory --hidden`,
		)
		.split("\r")
		.reverse() // since often used files in `zsh` or `nvim` or further down the alphabet
		.map((/** @type {string} */ absPath) => {
			const name = absPath.slice(0, -1).split("/").pop();
			if (!name) return {};
			const relPath = absPath.slice(dotfileFolder.length);
			const relativeParentFolder = relPath.slice(1, -name.length - 2) || "/";

			return {
				title: name,
				subtitle: "▸ " + relativeParentFolder,
				match: alfredMatcher(name) + " folder",
				icon: { type: "fileicon", path: absPath },
				type: "file:skipcheck",
				uid: absPath,
				arg: absPath,
			};
		});

	return JSON.stringify({
		items: [...fileArray, ...folderArray],
		cache: { seconds: 120 }, // quick for newly created files
	});
}
