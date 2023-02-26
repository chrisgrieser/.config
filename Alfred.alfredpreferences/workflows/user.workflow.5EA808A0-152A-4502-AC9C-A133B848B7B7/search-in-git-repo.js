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
		if (name.startsWith(".z")) type = "zsh";
		else if (name.startsWith(".")) type = "config";
		else type = name.split(".").pop();

		// icon determination
		let iconObj = { path: "./../filetype-icons/" };
		switch (type) {
			case "json":
			case "lua":
			case "html":
			case "pdf":
			case "bib":
			case "css":
			case "md":
			case "js":
			case "ts":
			case "yaml":
			case "config":
			case "blank":
			case "sh":
				iconObj.path += type + ".png";
				break;
			case "yml":
				iconObj.path += "yaml.png";
				break;
			case "zsh":
				iconObj.path += "sh.png";
				break;
			case "scss":
				iconObj.path += "css.png";
				break;
			case "icns":
			case "png":
			case "gif":
				iconObj.path = fPath; // use image itself
				break;
			case "folder":
			default:
				iconObj = { type: "fileicon", path: fPath };
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
