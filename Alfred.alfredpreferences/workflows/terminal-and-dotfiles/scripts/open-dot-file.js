#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
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
	const dirtyFiles = app
		.doShellScript(`cd "${dotfileFolder}" && git status --porcelain`)
		.split("\r")
		.map((/** @type {string} */ file) => file.replace(/^(\?\? | M | R .*? -> )/, ""));

	/** @type{AlfredItem[]} */
	const fileArray = [];
	const fileList = app
		.doShellScript(
			// INFO using `fd` over `find` for speed and gitignoring
			`PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; cd "${dotfileFolder}" ;
			fd --type=file --hidden --absolute-path --exclude "*.png"`,
		)
		.split("\r");

	for (const absPath of fileList) {
		const name = absPath.split("/").pop();
		if (!name) return;

		const relPath = absPath.slice(dotfileFolder.length + 1);
		const relativeParentFolder = relPath.slice(0, -name.length - 1) || "/";
		const matcher = alfredMatcher(`${name} ${relativeParentFolder}`);
		const isDirty = dirtyFiles.includes(relPath);

		// emoji
		let emoji = "";
		if (isDirty) emoji += " ✴️";
		if (relPath.includes("hammerspoon")) emoji += " 🟡";
		else if (relPath.includes("nvim")) emoji += " 🔳";

		// type-icon
		let type = "";
		if (name.startsWith(".z")) type = "zsh"; // .zshenv, .zshrc, .zprofile
		else if (name.endsWith("akefile")) type = "make";
		else if (name.startsWith(".")) type = "cfg";
		else if (!name.includes(".")) type = "blank";
		else if (name === "obsidian-vimrc.vim") type = "obsidian";
		else type = name.split(".").pop() || ""; // default: extension

		const iconObj = {};
		switch (type) {
			case "webloc":
			case "url":
			case "ini":
			case "mjs":
				iconObj.type = "fileicon";
				iconObj.path = absPath;
				break;
			default:
				iconObj.path = `./custom-filetype-icons/${type}.png`; // use {extension}.png located in icon folder
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

		// if dirty, insert in front of array
		const insertAt = isDirty ? "unshift" : "push";
		fileArray[insertAt](item);
	}

	/** @type{AlfredItem[]} */
	const folderArray = app
		.doShellScript(
			`PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; cd "${dotfileFolder}" ;
			fd --absolute-path --type=directory --hidden`,
		)
		.split("\r")
		.map((/** @type {string} */ absPath) => {
			const name = absPath.slice(0, -1).split("/").pop();
			if (!name) return;
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

	const pwPath = app.doShellScript('source $HOME/.zshenv && echo "$PASSWORD_STORE_DIR"');
	/** @type{AlfredItem} */
	const passwordStore = {
		title: ".password-store",
		match: alfredMatcher(pwPath) + " folder",
		icon: { type: "fileicon", path: pwPath },
		type: "file:skipcheck",
		uid: pwPath,
		arg: pwPath,
	};

	return JSON.stringify({ items: [...fileArray, ...folderArray, passwordStore] });
}
