#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	// try out all the different casings
	const clean = str.replace(/[-.()_/[\]]/g, " ");
	const squeezed = str.replace(/[-_.]/g, "");
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
	const expPath = "PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH";
	const dirtyFiles = app.doShellScript(`git -C "${dotfileFolder}" diff --name-only`).split("\r");

	// `--follow` errors on broken symlinks, so we need to exit with `true`
	const rgOutput = app
		.doShellScript(
			`${expPath} ; rg --no-config --files --hidden --follow --sortr=modified \
			--ignore-file=${dotfileFolder}/rg/ignore "${dotfileFolder}" 2>&1 || true`,
		)
		.split("\r");

	// GUARD broken symlinks
	if (rgOutput[0].endsWith("No such file or directory (os error 2)")) {
		const [_, brokenLink] = rgOutput[0].match(/rg: (.+?): /) || [];
		const relPath = brokenLink.slice(dotfileFolder.length + 1);
		const alfredItem = {
			title: relPath,
			subtitle: "⚠️ Broken Symlink",
			type: "file:skipcheck", // so `alt+return` reveals it in Finder
			arg: brokenLink,
		};
		return JSON.stringify({ items: [alfredItem] });
	}

	/** @type{AlfredItem|{}[]} */
	const fileArray = rgOutput.map((absPath) => {
		const name = absPath.split("/").pop() || "ERROR";
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
		if (name.startsWith(".z"))
			type = "zsh"; // .zshenv, .zshrc, .zprofile
		else if (name === "Justfile") type = "justfile";
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
			iconObj.path = absPath;
		} else {
			iconObj.path = `./custom-filetype-icons/${type}.png`; // use {ext}.png in icon folder
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
		.doShellScript(`
			find "${dotfileFolder}" -type d \
			-not -path "**/.git/*" \
			-not -path "**/Alfred.alfredpreferences/*" \
			-not -path "**/Spoons/*"
		`)
		.split("\r")
		.map((/** @type {string} */ absPath) => {
			const name = absPath.split("/").pop();
			if (!name) return {};
			const relPath = absPath.slice(dotfileFolder.length);
			const relativeParentFolder = relPath.slice(1, -name.length - 1) || "/";

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

	return JSON.stringify({ items: [...fileArray, ...folderArray] });
}
