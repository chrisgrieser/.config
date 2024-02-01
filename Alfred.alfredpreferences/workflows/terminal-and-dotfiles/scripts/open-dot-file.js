#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#;,/\\[\]]/g, " ");
	const squeezed = str.replace(/[-_.]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	const kebabCase = str.replace(/[ _]/g, "-")
	const snakeCase = str.replace(/[ -]/g, "_")
	return [clean, camelCaseSeparated, squeezed, str, kebabCase, snakeCase].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: alfred run
function run() {
	const dotfileFolder = $.getenv("dotfile_folder");

	// FILES
	const dirtyFiles = app
		.doShellScript(`cd "${dotfileFolder}" && git status --porcelain`)
		.split("\r")
		.map((/** @type {string} */ file) => file.replace(/^(\?\? | M | R .*? -> )/, ""));

	/** @type{AlfredItem[]} */
	const fileArray = app
		.doShellScript(
			// INFO using `fd` over `find` for speed and gitignoring
			`PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; cd "${dotfileFolder}" ;
			fd --type=file --hidden --absolute-path -E "*.png"`,
		)
		.split("\r")
		.map((/** @type {string} */ absPath) => {
			const name = absPath.split("/").pop();
			if (!name) return;

			let icon = "";
			const relPath = absPath.slice(dotfileFolder.length + 1);
			const relativeParentFolder = relPath.slice(0, -name.length - 1) || "/";
			let matcher = alfredMatcher(`${name} ${relativeParentFolder}`);

			// dirty?
			if( dirtyFiles.includes(relPath)) {
				icon += " ✴️";
			}

			matcher += " dirty";

			// type determination
			let type = "";
			if (name.startsWith(".z")) type = "zsh"; // .zshenv, .zshrc, .zprofile
			else if (name.endsWith("akefile")) type = "make";
			else if (name.startsWith(".")) type = "cfg";
			else if (!name.includes(".")) type = "blank";
			else if (name === "obsidian-vimrc.vim") type = "obsidian";
			else type = name.split(".").pop() || ""; // default: extension

			// icon determination
			let iconObj = { path: "./custom-filetype-icons/" };
			switch (type) {
				// use filetype image
				case "webloc":
				case "url":
				case "folder":
				case "ini":
				case "mjs":
					iconObj = { type: "fileicon", path: absPath };
					break;
				case "zsh":
					// biome-ignore lint/suspicious/noFallthroughSwitchClause: intentional fallthrough
					type = "sh"
				case "yml":
					// biome-ignore lint/suspicious/noFallthroughSwitchClause: intentional fallthrough
					type = "yaml"
				default:
					iconObj.path += type + ".png"; // use {extension}.png located in icon folder
			}

			// icons to distinguish all these lua files I have…
			if (relPath.includes("hammerspoon")) icon += " 🟡";
			else if (relPath.includes("nvim")) icon += " 🔳";

			return {
				title: name + dirtyIcon + icon,
				match: matcher,
				subtitle: "▸ " + relativeParentFolder,
				icon: iconObj,
				type: "file:skipcheck",
				uid: absPath,
				arg: absPath,
			};
		});

	//──────────────────────────────────────────────────────────────────────────────

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

	//──────────────────────────────────────────────────────────────────────────────

	// password-store (pass-cli)
	const pwPath = app.pathTo("home folder") + "/.password-store";
	const repoPath = app.doShellScript('source $HOME/.zshenv && echo "$LOCAL_REPOS"');
	/** @type{AlfredItem[]} */
	const extraFolders = [
		{
			title: ".password-store",
			match: alfredMatcher(pwPath) + " folder",
			icon: { type: "fileicon", path: pwPath },
			type: "file:skipcheck",
			uid: pwPath,
			arg: pwPath,
		},
		{
			title: "Repos",
			match: alfredMatcher(repoPath) + " folder",
			icon: { type: "fileicon", path: repoPath },
			type: "file:skipcheck",
			uid: repoPath,
			arg: repoPath,
		},
	];

	//──────────────────────────────────────────────────────────────────────────────

	const jsonArray = [...fileArray, ...folderArray, ...extraFolders];
	return JSON.stringify({ items: jsonArray });
}
