#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#;,/\\[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────

const folderToSearch = $.getenv("folderToSearch");

// FILES
const dirtyFiles = app
	.doShellScript(`cd "${folderToSearch}" && git status --porcelain`)
	.split("\r")
	.map(file => file.replace(/^[ MD?]* /i, ""));

/** @type{AlfredItem[]} */
const filesArray = app
	.doShellScript(
		`cd "${folderToSearch}"
		fd --type=file --hidden --absolute-path --exclude ".git/"`,
	)
	.split("\r")
	/* eslint-disable-next-line complexity */
	.map(absPath => {
		const name = absPath.split("/").pop();
		const relPath = absPath.slice(folderToSearch.length);
		const relativeParentFolder = relPath.slice(0, -(name.length + 1));

		const fileIsDirty = dirtyFiles.includes(relPath);
		const dirtyIcon = fileIsDirty ? " ✴️" : "";
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
		let iconObj = { path: "./../../../_custom-filetype-icons/" };
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
			case "webloc":
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
/** @type{AlfredItem[]} */
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

//──────────────────────────────────────────────────────────────────────────────
// MERGE AND SORT array by important extensions
// (even though Alfred does sorting since due to the `uid` key, the sorting does
// only happens for recently visited repos, so for the other cases, this sorting
// here is useful)
/** @type{AlfredItem[]} */
const jsonArray = [...filesArray, ...folderArray].sort((a, b) => {
	const aExt = a.title.split(".").pop();
	const bExt = b.title.split(".").pop();
	const priorityExt = ["lua", "ts", "md", "js", "py"];
	const aHasPrio = priorityExt.includes(aExt);
	const bHasPrio = priorityExt.includes(bExt);
	if (aHasPrio && !bHasPrio) return -1;
	if (!aHasPrio && bHasPrio) return 1;
	return 0;
});

JSON.stringify({ items: jsonArray }); // direct return
