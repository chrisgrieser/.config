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
	.map(fPath => {
		const parts = fPath.split("/");
		const isFolder = fPath.endsWith("/");
		if (isFolder) parts.pop();
		const name = parts.pop();
		const relativeParentFolder = fPath.slice(folderToSearch.length, -(name.length + 1));

		let iconObj;
		let ext = name.split(".").pop();
		if (ext.includes("rc")) ext = "rc"; // rc files
		else if (ext.startsWith("z")) ext = "zsh"; // zsh dotfiles
		switch (ext) {
			case "json":
				iconObj = { "path": "icons/json.png" };
				break;
			case "lua":
				iconObj = { "path": "icons/lua.png" };
				break;
			case "yaml":
			case "yml":
				iconObj = { "path": "icons/yaml.png" };
				break;
			case "md":
				iconObj = { "path": "icons/markdown-file.png" };
				break;
			case "js":
				iconObj = { "path": "icons/js.png" };
				break;
			case "zsh":
			case "sh":
				iconObj = { "path": "icons/shell.png" };
				break;
			case "rc":
				iconObj = { "path": "icons/rc.png" };
				break;
			case "png":
				iconObj = { "path": fPath }; // if png, use image itself
				break;
			case "": // = folder
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
