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
	const dotfileFolder = $.getenv("dotfile_folder");
	const modifiedFiles = app
		.doShellScript(`git -C "${dotfileFolder}" diff --name-only`)
		.split("\r");
	const rgOutput = app
		.doShellScript(
			// `--follow` errors on broken symlinks, so we need to end with `true`
			`PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; \
			rg --no-config --files --hidden --follow --sortr=modified \
			--ignore-file=${dotfileFolder}/ripgrep/ignore "${dotfileFolder}" 2>&1 || true`,
		)
		.split("\r");

	/** @type{AlfredItem|{}[]} */
	// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: <explanation>
	const fileArray = rgOutput.map((absPath) => {
		// GUARD check for broken symlinks
		if (absPath.startsWith("rg: ")) {
			const [_, brokenLink] = absPath.match(/rg: (.+?): /) || [];
			const relPath = brokenLink.slice(dotfileFolder.length + 1);
			const alfredItem = {
				title: relPath,
				subtitle: "⚠️ Broken symlink",
				type: "file:skipcheck", // so `alt+return` reveals it in Finder
				arg: brokenLink,
			};
			return alfredItem;
		}

		// params
		const name = absPath.split("/").pop() || "ERROR";
		const relPath = absPath.slice(dotfileFolder.length + 1);
		const relativeParentFolder = relPath.slice(0, -name.length - 1) || "/";
		const matcher = alfredMatcher(`${name} ${relativeParentFolder}`);

		// emoji
		let emoji = "";
		if (relPath.includes("hammerspoon")) emoji += " 🟡";
		else if (relPath.includes("nvim")) emoji += " 🔳";
		if (modifiedFiles.includes(relPath)) emoji += " ✴️";

		// type-icon
		let type = "";
		if (name.startsWith(".z")) type = "zsh";
		else if (name === "Justfile") type = "justfile";
		else if (name === ".ignore" || name === ".gitignore") type = "ignore";
		else if (!name.slice(1).includes(".")) type = "blank";
		else if (name === "obsidian-vimrc.vim") type = "obsidian";
		else type = name.split(".").pop() || ""; // default: extension

		/** @type {{type: "" | "fileicon"; path: string}} */
		const iconObj = { type: "", path: "" };
		const useFileicon = ["webloc", "url", "ini", "mjs"].includes(type);
		const isImageFile = ["png", "icns", "webp"].includes(type);
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
			arg: absPath,
		};
		return item;
	});

	/** @type{AlfredItem|{}[]} */
	const folderArray = app
		.doShellScript(`
			find "${dotfileFolder}" -type d \
			-not -path "**/.git/*" \
			-not -path "**/*.app/*" \
			-not -path "**/Alfred.alfredpreferences/*" \
			-not -path "**/hammerspoon/Spoons/*"
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
				arg: absPath,
			};
		});

	return JSON.stringify({ items: [...fileArray, ...folderArray] });
}
