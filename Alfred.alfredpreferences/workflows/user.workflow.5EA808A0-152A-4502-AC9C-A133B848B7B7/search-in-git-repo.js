#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#;,/\\[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

const jsonArray = [];
const folderToSearch = $.getenv("folderToSearch");

// using `fd` over `find` for speed and gitignoring
const repoArray = app
	.doShellScript(
		`export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ;
		cd "${folderToSearch}" ;
		fd --absolute-path --hidden --exclude "/.git/*"`,
	)
	.split("\r")
	/* eslint-disable-next-line complexity */
	.map(fPath => {
		const parts = fPath.split("/");
		const isFolder = fPath.endsWith("/");
		if (isFolder) parts.pop();
		const name = parts.pop();
		const relativeParentFolder = fPath.slice(folderToSearch.length, -(name.length + 1));

		// type determiniation
		let type;
		if (isFolder) type = "folder";
		if (name.startsWith(".z")) type = "sh"; // zsh config
		else if (name.startsWith(".")) type = "config";
		else if (!name.includes(".")) type = "blank"; /* eslint-disable-line no-negated-condition */
		else name.split(".").pop();

		// icon determination
		let iconObj = { path: "./../filetype-icons/" };
		switch (type) {
			case "json":
				iconObj.path += "json.png";
				break;
			case "lua":
				iconObj.path += "lua.png";
				break;
			case "yaml":
			case "yml":
				iconObj.path += "yaml.png";
				break;
			case "scss":
			case "css":
				iconObj.path += "css.png";
				break;
			case "md":
				iconObj.path += "md.png";
				break;
			case "js":
				iconObj.path += "js.png";
				break;
			case "ts":
				iconObj.path += "ts.png";
				break;
			case "sh":
				iconObj.path += "sh.png";
				break;
			case "icns":
			case "png":
				iconObj.path = fPath; // use image itself
				break;
			case "gif":
				iconObj.path += "image.png";
				break;
			case "blank":
				iconObj.path += "blank.png";
				break;
			case "config":
				iconObj.path += "blank.png";
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

if (!repoArray.length) {
	jsonArray.push({ title: "No file in the current Folder found." });
	JSON.stringify({ items: jsonArray });
}

JSON.stringify({ items: repoArray });
