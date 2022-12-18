#!/usr/bin/env osascript -l JavaScript
// requires 'fd' cli

//──────────────────────────────────────────────────────────────────────────────
ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const home = app.pathTo("home folder");
const finderApp = Application("Finder");
//──────────────────────────────────────────────────────────────────────────────

const pathsToSearch = [
	$.getenv("working_folder").replace(/^~/, home),
	$.getenv("dotfile_folder").replace(/^~/, home),
	$.getenv("dotfile_folder").replace(/^~/, home) + "/nvim/my-plugins",
	$.getenv("dotfile_folder").replace(/^~/, home) + "/Alfred.alfredpreferences/workflows",
	home + "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Development/.obsidian/plugins",
	home + "/Library/Mobile Documents/com~apple~CloudDocs/Repos",
];

//──────────────────────────────────────────────────────────────────────────────

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

function readPlist(key, path) {
	return app
		.doShellScript(
			"plutil -extract " + key + " xml1 -o - '" + path + '\' | sed -n 4p | cut -d">" -f2 | cut -d"<" -f1',
		)
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

pathsToSearch.forEach(path => {
	pathString += '"' + path + '" ';
});
const repoArray = app
	.doShellScript(
		"export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; fd '\\.git$' --no-ignore --hidden --max-depth=2 " + pathString,
	)
	.split("\r")
	.map(i => i.slice(0, -5))
	.filter(i => !i.endsWith(".spoon/")); // no hammerspoon spoons

repoArray.forEach(localRepoFilePath => {
	let repoName;
	const isAlfredWorkflow = finderApp.exists(Path(localRepoFilePath + "/info.plist"));
	const isObsiPlugin = finderApp.exists(Path(localRepoFilePath + "/manifest.json"));
	const isNeovimPlugin = finderApp.exists(Path(localRepoFilePath + "/lua"));

	// Dirty Repo
	let dirtyIcon = "";
	const dirtyRepo = app.doShellScript(`cd "${localRepoFilePath}" && git status --porcelain`) !== "";
	if (dirtyRepo) dirtyIcon = " ✴️";

	let iconpath = "repotype-icons/";
	if (isAlfredWorkflow) {
		repoName = readPlist("name", localRepoFilePath + "/info.plist");
		iconpath = localRepoFilePath + "/icon.png";
	} else if (isObsiPlugin) {
		const manifest = readFile(localRepoFilePath + "/manifest.json");
		repoName = JSON.parse(manifest).name;
		iconpath += "obsidian.png";
	} else if (isNeovimPlugin) {
		repoName = localRepoFilePath.replace(/.*\/(.*)/, "$1");
		iconpath += "neovim.png";
	} else {
		const readme = readFile(localRepoFilePath + "/README.md");
		const isKarabinerMod = readme.includes("Karabiner");
		if (isKarabinerMod) iconpath += "karabiner.png";

		if (readme) {
			repoName = readme
				.split("\n")
				.find(line => line.startsWith("# "))
				.replace(/^#+ /, "");
			if (!repoName) repoName = "Heading Missing";
		} else {
			repoName = localRepoFilePath;
		}
	}

	jsonArray.push({
		title: repoName + dirtyIcon,
		match: alfredMatcher(repoName),
		icon: { path: iconpath },
		arg: localRepoFilePath,
		uid: localRepoFilePath,
	});
});

JSON.stringify({ items: jsonArray });
