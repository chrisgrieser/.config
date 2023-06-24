#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

/** @param {string} filepath @return {Date} */
function dateAddedToFolder(filepath) {
	const dateString = app
			.doShellScript(`mdls -name kMDItemDateAdded "${filepath}"`)
			.split(" = ")[1]
			.replaceAll(" +", "+")
	if (dateString.includes("(null)")) return null;
	return new Date (dateString);
}

//──────────────────────────────────────────────────────────────────────────────

const home = app.pathTo("home folder");
const trashLocation1 = home + "/.Trash";
const trashLocation2 = home + "/Library/Mobile Documents/com~apple~CloudDocs/.Trash";

//──────────────────────────────────────────────────────────────────────────────

/** @type{AlfredItem[]} */
const jsonArray = app
	.doShellScript(`find "${trashLocation1}" "${trashLocation2}" -maxdepth 1 -mindepth 1`)
	.split("\r")
	.map((path) => {
		const ext = path.split(".").pop();
		const filename = path.split("/").pop();

		const iconToDisplay = { path: path };
		const imageExtensions = ["png", "jpg", "jpeg", "gif", "icns", "tiff", "heic", "pdf"];
		if (!imageExtensions.includes(ext)) iconToDisplay.type = "fileicon";

		return {
			title: filename,
			match: alfredMatcher(path),
			type: "file:skipcheck",
			arg: path,
			icon: iconToDisplay,
			date: dateAddedToFolder(path), // not used by Alfred, only for sorting
		};
	})
	.sort((a, b) => {
		return b.date - a.date;
	}))


JSON.stringify({ items: jsonArray });
