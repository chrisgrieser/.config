#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#;,/\\[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

//──────────────────────────────────────────────────────────────────────────────
// using `fd` over `find` for speed and gitignoring
const jsonArray = [];
const dotfileFolder = $.getenv("dotfile_folder").replace(/^~/, app.pathTo("home folder"));
/* eslint-disable no-multi-str, quotes */
const workArray = app
	.doShellScript(
		'PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; cd "' +
			dotfileFolder +
			'" ; fd --hidden --no-ignore \
		-E "Alfred.alfredpreferences" \
		-E "alacritty/colors/*" \
		-E "hammerspoon/Spoons/*" \
		-E "*/vale/styles/*/*.yml" \
		-E "*/vale/styles/*/*.adoc" \
		-E "*/vale/styles/*/*.md" \
		-E "**/*.app/*" \
		-E "karabiner/automatic_backups" \
		-E "visualized-keyboard-layout/*.json" \
		-E "zsh/plugins/*" \
		-E "nvim/my-plugins/*" \
		-E "*.icns" \
		-E "*.plist" \
		-E "*.add" \
		-E "*.spl" \
		-E "TODO*" \
		-E "INFO*" \
		-E "*.png" \
		-E "Fonts/*" \
		-E ".DS_Store" \
		-E ".git/" \
		-E ".git"',
	)
	.split("\r");
/* eslint-enable no-multi-str, quotes */

/* eslint-disable-next-line complexity */
workArray.forEach(file => {
	const fPath = dotfileFolder + file;
	const parts = file.split("/");
	const isFolder = file.endsWith("/");
	if (isFolder) parts.pop();
	const name = parts.pop();

	let parentPart = fPath.replace(/\/Users\/.*?\.config\/(.*\/).*$/, "$1");
	if (parentPart === ".") parentPart = "";

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

	let matcher = alfredMatcher(`${name} ${parentPart}`);
	if (isFolder) matcher += " folder";

	jsonArray.push({
		title: name,
		subtitle: "▸ " + parentPart,
		match: matcher,
		icon: iconObj,
		type: "file:skipcheck",
		uid: fPath,
		arg: fPath,
	});
});

//──────────────────────────────────────────────────────────────────────────────

// add dotfile folder itself + password-store (pass-cli)
const self = dotfileFolder.replace(/.*\/(.+)\//, "$1");
jsonArray.push({
	title: self,
	subtitle: "▸ root",
	match: alfredMatcher(self),
	icon: { type: "fileicon", path: dotfileFolder },
	type: "file:skipcheck",
	uid: self,
	arg: dotfileFolder,
});

const pwPath = app.pathTo("home folder") + "/.password-store";
jsonArray.push({
	title: ".password-store",
	match: alfredMatcher(pwPath),
	icon: { type: "fileicon", path: pwPath },
	type: "file:skipcheck",
	uid: pwPath,
	arg: pwPath,
});

JSON.stringify({ items: jsonArray });
