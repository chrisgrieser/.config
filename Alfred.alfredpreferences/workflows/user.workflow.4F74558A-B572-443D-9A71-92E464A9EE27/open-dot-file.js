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
const dotfileFolder = $.getenv("dotfile_folder").replace(/^~/, app.pathTo("home folder"));
const fileArray = app
	.doShellScript(
		`
		PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
		cd "${dotfileFolder}"
		fd --type=file --hidden --no-ignore \\
			-E "Alfred.alfredpreferences" \\
			-E "alacritty/colors/*" \\
			-E "hammerspoon/Spoons/*" \\
			-E "*/vale/styles/*/*.yml" \\
			-E "*/vale/styles/*/*.adoc" \\
			-E "*/vale/styles/*/*.md" \\
			-E "**/*.app/*" \\
			-E "karabiner/automatic_backups" \\
			-E "visualized-keyboard-layout/*.json" \\
			-E "zsh/plugins/*" \\
			-E "nvim/my-plugins/*" \\
			-E "*.icns" \\
			-E "*.plist" \\
			-E "*.add" \\
			-E "*.spl" \\
			-E "TODO*" \\
			-E "INFO*" \\
			-E "*.png" \\
			-E "Fonts/*" \\
			-E ".DS_Store" \\
			-E ".git/" \\
			-E ".git" \\
	`,
	)
	.split("\r")
	/* eslint-disable-next-line complexity */
	.map(file => {
		const fPath = dotfileFolder + file;
		const parts = file.split("/");
		const name = parts.pop();
		let parentPart = fPath.replace(/\/Users\/.*?\.config\/(.*\/).*$/, "$1");
		if (parentPart === ".") parentPart = "";

		// type determiniation
		let type;
		if (name.startsWith(".z")) type = "sh";
		else if (name.startsWith(".")) type = "config";
		else if (!name.includes(".")) type = "blank"; /* eslint-disable-line no-negated-condition */
		else type = name.split(".").pop();
		const matcher = alfredMatcher(`${name} ${parentPart}`);

		// icon determination
		let iconObj = { path: "./../filetype-icons/" };
		switch (type) {
			case "json":
			case "lua":
			case "html":
			case "pdf":
			case "bib":
			case "css":
			case "md":
			case "js":
			case "ts":
			case "log":
			case "yaml":
			case "config":
			case "blank":
			case "sh":
				iconObj.path += type + ".png";
				break;
			case "yml":
				iconObj.path += "yaml.png";
				break;
			case "zsh":
				iconObj.path += "sh.png";
				break;
			case "scss":
				iconObj.path += "css.png";
				break;
			case "icns":
			case "png":
			case "gif":
				iconObj.path = fPath; // use image itself
				break;
			case "folder":
			default:
				iconObj = { type: "fileicon", path: fPath };
		}

		return {
			title: name,
			subtitle: "▸ " + parentPart,
			match: matcher,
			icon: iconObj,
			type: "file:skipcheck",
			uid: fPath,
			arg: fPath,
		};
	});

const folderArray = app
	.doShellScript(
		`
		PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
		cd "${dotfileFolder}" ;
		fd --type=directory --hidden --no-ignore \\
			-E "Alfred.alfredpreferences/**" \\
			-E "**/*.app/*" \\
			-E "karabiner/automatic_backups" \\
			-E "zsh/plugins/*" \\
			-E "nvim/my-plugins/*" \\
			-E ".git" \\
	`,
	)
	.split("\r")
	.map(file => {
		const fPath = dotfileFolder + file;
		const parts = file.slice(0, -1).split("/");
		const name = parts.pop();
		let parentPart = fPath.replace(/\/Users\/.*?\.config\/(.*\/).*$/, "$1");
		if (parentPart === ".") parentPart = "";

		return {
			title: name,
			subtitle: "▸ " + parentPart,
			match: alfredMatcher(name) + " folder",
			icon: { type: "fileicon", path: fPath },
			type: "file:skipcheck",
			uid: fPath,
			arg: fPath,
		};
	});

// password-store (pass-cli)
const pwPath = app.pathTo("home folder") + "/.password-store";
const pwFolder = {
	title: ".password-store",
	match: alfredMatcher(pwPath) + " folder",
	icon: { type: "fileicon", path: pwPath },
	type: "file:skipcheck",
	uid: pwPath,
	arg: pwPath,
};

//──────────────────────────────────────────────────────────────────────────────
const jsonArray = [...fileArray, ...folderArray, pwFolder];
JSON.stringify({ items: jsonArray });
