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
		if (name.startsWith(".z")) type = "zsh";
		else if (name.startsWith(".")) type = "config";
		else if (!name.includes(".")) type = "blank"; /* eslint-disable-line no-negated-condition */
		else type = name.split(".").pop();
		const matcher = alfredMatcher(`${name} ${parentPart}`);

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
			case "blank":
				iconObj.path += "blank.png";
				break;
			case "config":
				iconObj.path += "config.png";
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
	.doShellScript(`find "${dotfileFolder}" -type d -not -path "**/.git**" -not -path "**/node_modules**"`)
	.split("\r")
	.map(file => {
		const fPath = dotfileFolder + file;
		const parts = file.split("/");
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
