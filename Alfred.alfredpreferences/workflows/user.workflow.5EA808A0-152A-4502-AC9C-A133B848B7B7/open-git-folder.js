#!/usr/bin/env osascript -l JavaScript
// INFO requires 'fd' cli

//──────────────────────────────────────────────────────────────────────────────
ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const home = app.pathTo("home folder");
const fileExists = filePath => Application("Finder").exists(Path(filePath));
//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const pathsToSearch = [
	$.getenv("dotfile_folder").replace(/^~/, home),
	$.getenv("local_repo_folder").replace(/^~/, home),
	$.getenv("dotfile_folder").replace(/^~/, home) + "/Alfred.alfredpreferences/workflows",
	home + "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Development/.obsidian/plugins",
];

//──────────────────────────────────────────────────────────────────────────────

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

function readPlist(key, path) {
	return app
		.doShellScript(`plutil -extract ${key} xml1 -o - '${path}' | sed -n 4p | cut -d">" -f2 | cut -d"<" -f1`)
		.replaceAll("&amp;", "&");
}

function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────

const jsonArray = [];
let pathString = "";

pathsToSearch.forEach(path => (pathString += '"' + path + '" '));
const repoArray = app
	.doShellScript(
		"export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; fd '\\.git$' --no-ignore --hidden --max-depth=2 " +
			pathString,
	)
	.split("\r")
	.map(i => i.replace(/\.git\/?$/, ""))

repoArray.forEach(localRepoFilePath => {
	const repoID = localRepoFilePath.replace(/.*\//, "");

	// Dirty Repo
	const repoIsDirty = app.doShellScript(`cd "${localRepoFilePath}" && git status --porcelain`) !== "";
	const dirtyIcon = repoIsDirty ? " ✴️" : "";

	let repoName;
	let iconpath = "repotype-icons/";

	const isAlfredWorkflow = fileExists(localRepoFilePath + "/info.plist");
	const isObsiPlugin = fileExists(localRepoFilePath + "/manifest.json");
	const isNeovimPlugin = fileExists(localRepoFilePath + "/lua");
	if (isAlfredWorkflow) {
		repoName = readPlist("name", localRepoFilePath + "/info.plist");
		iconpath = localRepoFilePath + "/icon.png";
	} else if (isObsiPlugin) {
		const manifest = readFile(localRepoFilePath + "/manifest.json");
		repoName = JSON.parse(manifest).name;
		iconpath += "obsidian.png";
	} else if (isNeovimPlugin) {
		repoName = localRepoFilePath.replace(/.*\/(.*)\//, "$1");
		iconpath += "neovim.png";
	} else if (localRepoFilePath.endsWith(".config/")) {
		repoName = "dotfiles";
		iconpath = "icon.png";
	} else {
		repoName = localRepoFilePath.replace(/.*\/(.*?)\/$/, "$1");
		iconpath = "icon.png";
	}

	jsonArray.push({
		title: repoName + dirtyIcon,
		match: alfredMatcher(repoName) + " " + alfredMatcher(repoID),
		icon: { path: iconpath },
		arg: localRepoFilePath,
		uid: repoID,
	});
});

JSON.stringify({ items: jsonArray });
