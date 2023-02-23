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
	.map(fPath => { /* eslint-disable-line complexity */
		const parts = fPath.split("/");
		const isFolder = fPath.endsWith("/");
		if (isFolder) parts.pop();
		const name = parts.pop();
		const relativeParentFolder = fPath.slice(folderToSearch.length, -(name.length + 1));

		let iconObj = { path: "./../filetype-icons/" };
		let ext = isFolder ? "folder" : name.split(".").pop();
		if (ext.startsWith("z")) ext = "zsh"; // zsh dotfiles

		switch (ext) {
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
			case "bash":
			case "sh":
				iconObj.path += "sh.png";
				break;
			case "png":
				iconObj.path = fPath; // if png, use image itself
				break;
			case "folder":
				iconObj = { type: "fileicon", path: fPath }; 
				break;
			default:
				iconObj.path += "config.png"; 
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
