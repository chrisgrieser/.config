#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
const getEnv = (path) => $.getenv(path).replace(/^~/, app.pathTo("home folder"));

const jsonArray = [];
const dotfileFolder = getEnv ("dotfile_folder");
/* eslint-disable no-multi-str, quotes */
const workArray = app.doShellScript (
	'PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ;\
	cd "' + dotfileFolder + '" ; fd -H \
	-E "Alfred.alfredpreferences" \
	-E ".config/alacritty/themes/" \
	-E "zsh/plugins/colorscript.bash" \
	-E ".config/karabiner/assets/complex_modifications/*.json" \
	-E "FileHistory*.json"'
).split("\r");
/* eslint-enable no-multi-str, quotes */

workArray.forEach(file => {
	const fPath = dotfileFolder + file.slice(1);
	const parts = file.split("/");
	const isFolder = file.endsWith("/");
	let name;
	if (isFolder) {
		parts.pop();
		name = parts.pop();
	}
	else name = parts.pop();

	let ext = name.split(".").pop();
	if (ext.includes("rc")) ext = "rc"; // rc files
	else if (ext.startsWith("z")) ext = "zsh"; // zsh dotfiles

	let parentFolder = parts.pop();
	if (parentFolder === ".") parentFolder = "";

	let iconObject;
	switch (ext) {
		case "json":
			iconObject = { "path": "icons/json.png" };
			break;
		case "yaml":
		case "yml":
			iconObject = { "path": "icons/yaml.png" };
			break;
		case "js":
			iconObject = { "path": "icons/js.png" };
			break;
		case "zsh":
		case "sh":
			iconObject = { "path": "icons/shell.png" };
			break;
		case "rc":
			iconObject = { "path": "icons/rc.png" };
			break;
		case "": // = folder
		default:
			iconObject = { "type": "fileicon", "path": fPath }; // by default, use file icon
	}

	jsonArray.push({
		"title": name,
		"subtitle": "▸ " + parentFolder,
		"match": alfredMatcher (name),
		"icon": iconObject,
		"type": "file:skipcheck",
		"uid": fPath,
		"arg": fPath,
	});
});

JSON.stringify({ items: jsonArray });
