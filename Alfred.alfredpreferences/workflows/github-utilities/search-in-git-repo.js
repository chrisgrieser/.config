#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#;,/\\[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

const folderToSearch = $.getenv("folderToSearch");

//──────────────────────────────────────────────────────────────────────────────

// FILES
const dirtyFiles = app
	.doShellScript(`cd "${folderToSearch}" && git status --porcelain`)
	.split("\r")
	.map(file => file.replace(/^[ MD?]* /i, ""));

const fileArray = app
	.doShellScript(
		`cd "${folderToSearch}"
		fd --type=file --hidden --absolute-path --exclude ".git/" --exclude ".git"`,
	)
	.split("\r")
	/* eslint-disable-next-line complexity */
	.map(absPath => {
		const name = absPath.split("/").pop();
		const relPath = absPath.slice(folderToSearch.length);
		const relativeParentFolder = relPath.slice(0, -(name.length + 1));

		const fileIsDirty = dirtyFiles.includes(relPath);
		const dirtyIcon = fileIsDirty ? ` ${$.getenv("dirty_icon")}` : "";
		let matcher = alfredMatcher(name);
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
			case "plist":
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
			type: "file:skipcheck",
			icon: iconObj,
			arg: absPath,
			uid: absPath,
		};
	});

// FOLDERS
const folderArray = app
	.doShellScript(`find "${folderToSearch}" -type d -not -path "**/.git**" -not -path "**/node_modules**"`)
	.split("\r")
	.map(fPath => {
		const name = fPath.split("/").pop();
		const relativeParentFolder = fPath.slice(folderToSearch.length, -(name.length + 1));
		return {
			title: name,
			match: alfredMatcher(name) + " folder",
			subtitle: relativeParentFolder,
			type: "file:skipcheck",
			icon: { type: "fileicon", path: fPath },
			arg: fPath,
			uid: fPath,
		};
	});

const jsonArray = [...fileArray, ...folderArray];
if (!jsonArray.length) {
	jsonArray.push({ title: "No file in the current Folder found." });
	JSON.stringify({ items: jsonArray });
}

JSON.stringify({ items: jsonArray });
