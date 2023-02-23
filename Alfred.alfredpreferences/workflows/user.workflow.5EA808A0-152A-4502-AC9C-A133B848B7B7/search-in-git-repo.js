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

const repoArray = app
	.doShellScript(`find "${folderToSearch}" -not -path "**/.git**" -not -path "**/node_modules**"`)
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
			case "zsh":
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
			case "config":
				iconObj.path += "config.png";
				break;
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
