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
const fileArray = app
	.doShellScript(`find "${folderToSearch}" -type f -not -path "**/.git**" -not -path "**/node_modules**"`)
	.split("\r")
	/* eslint-disable-next-line complexity */
	.map(fPath => {
		const parts = fPath.split("/");
		const name = parts.pop();
		const relativeParentFolder = fPath.slice(folderToSearch.length, -(name.length + 1));

		// type determiniation
		let type;
		if (name.startsWith(".z")) type = "sh";
		else if (name.startsWith(".")) type = "config";
		else if (!name.includes(".")) type = "blank"; /* eslint-disable-line no-negated-condition */
		else if (name === "obsidian.vimrc") type = "obsidian";
		else type = name.split(".").pop();
		if (type === "yml") type = "yaml";
		if (type.endsWith("-bkp")) type = "other";

		// icon determination
		let iconObj = { path: "./../../../custom-filetype-icons/" };
		switch (type) {
			case "icns":
			case "png":
			case "gif":
				iconObj.path = fPath; // use image itself
				break;
			case "folder":
				iconObj = { type: "fileicon", path: fPath };
				break;
			default:
				iconObj.path += type + ".png";
		}

		return {
			title: name,
			match: alfredMatcher(name),
			subtitle: relativeParentFolder,
			type: "file:skipcheck",
			icon: iconObj,
			arg: fPath,
			uid: fPath,
		};
	});

// FOLDERS
const folderArray = app
	.doShellScript(`find "${folderToSearch}" -type d -not -path "**/.git**" -not -path "**/node_modules**"`)
	.split("\r")
	.map(fPath => {
		const parts = fPath.split("/");
		const name = parts.pop();
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
