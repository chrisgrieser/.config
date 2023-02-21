#!/usr/bin/env osascript -l JavaScript
// requires `fd`

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

/* eslint-disable no-multi-str */
const repoArray = app.doShellScript("export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; \
	cd \"" + folderToSearch + "\" ; \
	fd --absolute-path --hidden --exclude \"/.git/*\"")
	.split("\r")
	.map(fPath => { /* eslint-disable-line complexity */
		const parts = fPath.split("/");
		const isFolder = fPath.endsWith("/");
		if (isFolder) parts.pop();
		const name = parts.pop();
		const relativeParentFolder = fPath.slice(folderToSearch.length, -(name.length + 1));

		let iconObj = { "path": "./../filetype-icons/" };
		let ext = isFolder ? "folder" : name.split(".").pop();
		if (ext.includes("rc")) ext = "rc"; // rc files
		else if (ext.startsWith("z")) ext = "zsh"; // zsh dotfiles
		switch (ext) {
			case "json":
				iconObj.path += "json.png"
				break;
			case "lua":
				iconObj.path += "lua.png"
				break;
			case "yaml":
			case "yml":
				iconObj.path += "yaml.png"
				break;
			case "md":
				iconObj.path += "markdown.png"
				break;
			case "js":
				iconObj.path += "js.png"
				break;
			case "zsh":
			case "sh":
				iconObj.path += "shell.png"
				break;
			case "rc":
				iconObj.path += "rc.png"
				break;
			case "png":
				iconObj.path = fPath // if png, use image itself
				break;
			default:
				iconObj = { "type": "fileicon", "path": fPath }; // by default, use file icon
		}

		return {
			"title": name,
			"match": alfredMatcher(name),
			"subtitle": relativeParentFolder,
			"type": "file",
			"icon": iconObj,
			"arg": fPath,
			"uid": fPath,
		};
	});

if (!repoArray.length) {
	jsonArray.push({ "title": "No file in the current Folder found." });
	JSON.stringify({ items: jsonArray });
}

JSON.stringify({ items: repoArray });
