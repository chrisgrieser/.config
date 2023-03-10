#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#;,/\\[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────
// using `fd` over `find` for speed and gitignoring
const dotfileFolder = $.getenv("dotfile_folder").replace(/^~/, app.pathTo("home folder"));

// FILES
const dirtyFiles = app
	.doShellScript(`cd "${dotfileFolder}" && git status --porcelain`)
	.split("\r")
	.map(file => file.replace(/^[ MD?]* /i, ""));

const fileArray = app
	.doShellScript(
		`
		cd "${dotfileFolder}"
		fd --type=file --hidden --absolute-path \\
			-E "visualized-keyboard-layout/*.json" \\
			-E "*.icns" \\
			-E "*.plist" \\
			-E "*.png" \\
			-E "Fonts/*" \\
			-E ".git" \\
	`,
	)
	.split("\r")
	/* eslint-disable-next-line complexity */
	.map(absPath => {
		const name = absPath.split("/").pop();
		const relPath = absPath.slice(dotfileFolder.length);
		const relativeParentFolder = relPath.slice(0, -(name.length + 1));

		const fileIsDirty = dirtyFiles.includes(relPath);
		const dirtyIcon = fileIsDirty ? " ✴️" : "";
		let matcher = alfredMatcher(`${name} ${relativeParentFolder}`);
		if (fileIsDirty) matcher += " dirty";

		// type determiniation
		let type;
		if (name.startsWith(".z")) type = "sh";
		else if (name.startsWith(".")) type = "config";
		else if (!name.includes(".")) type = "blank"; /* eslint-disable-line no-negated-condition */
		else if (name === "obsidian.vimrc") type = "obsidian";
		else type = name.split(".").pop();

		if (type === "yml") type = "yaml";
		else if (type === "mjs") type = "js";
		else if (type === "zsh") type = "sh";
		else if (type === "conf") type = "config";
		else if (type.endsWith("-bkp")) type = "other";

		// icon determination
		let iconObj = { path: "./../../../custom-filetype-icons/" };
		switch (type) {
			case "icns":
			case "png":
			case "gif":
				iconObj.path = absPath; // use image itself
				break;
			case "bttpreset":
			case "opml":
			case "other":
			case "url":
			case "html":
			case "folder":
				iconObj = { type: "fileicon", path: absPath };
				break;
			default:
				iconObj.path += type + ".png";
		}

		return {
			title: name + dirtyIcon,
			match: matcher,
			subtitle: "▸ " + relativeParentFolder,
			icon: iconObj,
			type: "file:skipcheck",
			uid: absPath,
			arg: absPath,
		};
	});

const folderArray = app
	.doShellScript(
		` PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
		cd "${dotfileFolder}" ;
		fd --type=directory --hidden \\
		-E ".git"`,
	)
	.split("\r")
	.map(file => {
		const fPath = dotfileFolder + file;
		const parts = file.slice(0, -1).split("/");
		const name = parts.pop();
		let parentPart = fPath.replace(/\/Users\/.*?\.config\/(.*\/).*$/, "$1");
		if (parentPart === ".") parentPart = "";

		return {
			title: name,
			subtitle: "▸ " + parentPart,
			match: alfredMatcher(name) + " folder",
			icon: { type: "fileicon", path: fPath },
			type: "file:skipcheck",
			uid: fPath,
			arg: fPath,
		};
	});

// password-store (pass-cli)
const pwPath = app.pathTo("home folder") + "/.password-store";
const pwFolder = {
	title: ".password-store",
	match: alfredMatcher(pwPath) + " folder",
	icon: { type: "fileicon", path: pwPath },
	type: "file:skipcheck",
	uid: pwPath,
	arg: pwPath,
};

//──────────────────────────────────────────────────────────────────────────────
const jsonArray = [...fileArray, ...folderArray, pwFolder];
JSON.stringify({ items: jsonArray });
