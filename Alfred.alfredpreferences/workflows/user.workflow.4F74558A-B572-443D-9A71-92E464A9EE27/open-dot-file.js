#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#;,/\\[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}
const home = app.pathTo("home folder");
const getEnv = (path) => $.getenv(path).replace(/^~/, home);

//──────────────────────────────────────────────────────────────────────────────

const jsonArray = [];
const dotfileFolder = getEnv("dotfile_folder");
/* eslint-disable no-multi-str, quotes */
const workArray = app.doShellScript(
	'PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ;\
	cd "' + dotfileFolder + '" ; \
	fd --hidden --no-ignore \
	-E "Alfred.alfredpreferences" \
	-E "alacritty/colors/*" \
	-E "Marta/Themes/*" \
	-E "packer_compiled.lua" \
	-E "nvim/packer-snapshots/*" \
	-E "hammerspoon/Spoons/*" \
	-E "vale/styles/*/*.yml" \
	-E "vale/styles/*/*.adoc" \
	-E "vale/styles/*/*.md" \
	-E "**/*.app/*" \
	-E "karabiner/automatic_backups" \
	-E "visualized-keyboard-layout/*.json" \
	-E "*.icns" \
	-E "*.plist" \
	-E "TODO*" \
	-E "INFO*" \
	-E "*.png" \
	-E "Fonts/*" \
	-E ".DS_Store" \
	-E ".git/"'
).split("\r");
/* eslint-enable no-multi-str, quotes */

workArray.forEach(file => {
	const filePath = dotfileFolder + file;
	const parts = file.split("/");
	const isFolder = file.endsWith("/");
	if (isFolder) parts.pop();
	const fileName = parts.pop();

	let parentPart = filePath.replace(/\/Users\/.*?\.config\/(.*\/).*$/, "$1");
	if (parentPart === ".") parentPart = "";

	let iconObj;
	let ext = fileName.split(".").pop();
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
		case "": // = folder
		default:
			iconObj = { "type": "fileicon", "path": filePath }; // by default, use file icon
	}

	jsonArray.push({
		"title": fileName,
		"subtitle": "▸ " + parentPart,
		"match": alfredMatcher(`${fileName} ${parentPart}`),
		"icon": iconObj,
		"type": "file:skipcheck",
		"uid": filePath,
		"arg": filePath,
	});
});

//──────────────────────────────────────────────────────────────────────────────

// add dotfile folder itself + password-store (pass-cli)
const self = dotfileFolder.replace(/.*\/(.+)\//, "$1");
jsonArray.push({
	"title": self,
	"subtitle": "▸ root",
	"match": alfredMatcher(self),
	"icon": { "type": "fileicon", "path": dotfileFolder },
	"type": "file:skipcheck",
	"uid": self,
	"arg": dotfileFolder,
});

const pwPath = home + "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Authentification/.password-store";
jsonArray.push({
	"title": ".password-store",
	"subtitle": "▸ Dotfolder/Authentification/",
	"match": alfredMatcher(pwPath),
	"icon": { "type": "fileicon", "path": dotfileFolder },
	"type": "file:skipcheck",
	"uid": pwPath,
	"arg": pwPath,
});

JSON.stringify({ items: jsonArray });
