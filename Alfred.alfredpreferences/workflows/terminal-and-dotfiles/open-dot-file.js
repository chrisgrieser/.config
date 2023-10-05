#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#;,/\\[\]]/g, " ");
	const merged = str.replace(/[-_.]/g, "");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [merged, clean, camelCaseSeperated, str].join(" ");
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
		.map((/** @type {string} */ file) => file.replace(/^[ MD?]* /i, ""));


	// INFO using `fd` over `find` for speed and gitignoring
	/** @type{AlfredItem[]} */
	const fileArray = app
		.doShellScript(
			`PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; cd "${dotfileFolder}" ;
			fd --type=file --hidden --absolute-path \\
			-E "*.icns" -E "*.plist" -E "*.png" -E ".DS_Store"`,
		)
		.split("\r")
		.map((/** @type {string} */ absPath) => {
			const name = absPath.split("/").pop();
			if (!name) return;
			const relPath = absPath.slice(dotfileFolder.length);
			const relativeParentFolder = relPath.slice(1, -name.length - 1) || "/";

			// dirty?
			const fileIsDirty = dirtyFiles.includes(relPath);
			const dirtyIcon = fileIsDirty ? " ✴️" : "";
			let matcher = alfredMatcher(`${name} ${relativeParentFolder}`);
			if (fileIsDirty) matcher += " dirty";

			// type determiniation
			let type = "";
			if (name.startsWith(".z")) type = "sh";
			else if (name.endsWith("akefile")) type = "make";
			else if (name.startsWith(".")) type = "config";
			else if (!name.includes(".")) type = "blank";
			else if (name === "obsidian.vimrc") type = "obsidian";
			else type = name.split(".").pop() || ""; // default: extension

			if (type === "yml") type = "yaml";
			else if (type === "mjs" || type === "jxa") type = "js";
			else if (type === "zsh") type = "sh";
			else if (type === "conf" || type === "cfg" || type === "ini") type = "config";
			else if (type.endsWith("-bkp")) type = "other";

			// icon determination
			let iconObj = { path: "./../../../_custom-filetype-icons/" };
			switch (type) {
				// use image preview
				case "icns":
				case "png":
				case "gif":
				case "jpg":
					iconObj.path = absPath;
					break;
				// use filetype image
				case "bttpreset":
				case "opml":
				case "other":
				case "webloc":
				case "url":
				case "plist":
				case "html":
				case "folder":
					iconObj = { type: "fileicon", path: absPath };
					break;
				// use {extension}.png located in icon folder
				default:
					iconObj.path += type + ".png";
			}

			// icons to distinguish all these lua files 🙈
			let icon = "";
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
	const repoPath = app.pathTo("home folder") + "/Repos";
	/** @type{AlfredItem[]} */
	const extraFolder = [
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

	const jsonArray = [...fileArray, ...folderArray, ...extraFolder];
	return JSON.stringify({ items: jsonArray });
}
