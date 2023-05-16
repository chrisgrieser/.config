#!/usr/bin/env osascript -l JavaScript
// INFO requires 'fd' cli

//──────────────────────────────────────────────────────────────────────────────
ObjC.import("stdlib");
ObjC.import("Foundation");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

/**
 * @param {string} key
 * @param {string} path
 */
function readPlist(key, path) {
	return app
		.doShellScript(`plutil -extract ${key} xml1 -o - '${path}' | sed -n 4p | cut -d">" -f2 | cut -d"<" -f1`)
		.replaceAll("&amp;", "&");
}

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

const getFullPath = (/** @type {string} */ path) => $.getenv(path).replace(/^~/, app.pathTo("home folder"));
const fileExists = (/** @type {string} */ filePath) => Application("Finder").exists(Path(filePath));

//──────────────────────────────────────────────────────────────────────────────

const pathsToSearch = [getFullPath("dotfile_folder")];
if ($.getenv("local_repo_folder")) pathsToSearch.push(getFullPath("local_repo_folder"));
if ($.getenv("extra_folder_1")) pathsToSearch.push(getFullPath("extra_folder_1"));
if ($.getenv("extra_folder_2")) pathsToSearch.push(getFullPath("extra_folder_2"));

let pathString = "";
pathsToSearch.forEach(path => {pathString += `"${path}" `});

JSON.stringify({ items: app
	.doShellScript(
		`export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
		fd '\\.git$' --no-ignore --hidden --max-depth=2 ${pathString}`,
	)
	.split("\r")
	.map((/** @type {string} */ gitFolder) => {
		const localRepoFilePath = gitFolder.replace(/\.git\/?$/, "");
		const repoID = localRepoFilePath.replace(/.*\/(.*)\//, "$1");

		// Dirty Repo
		let dirtyIcon;
		try {
			const repoIsDirty	= app.doShellScript(`cd "${localRepoFilePath}" && git status --porcelain`) !== "";
			dirtyIcon = repoIsDirty ? ` ${$.getenv("dirty_icon")}` : "";
		} catch (_error) {
			// error occurs when there have been iCloud sync issues with the repo
			dirtyIcon = " (⚠️ repo invalid)";
		}

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

		return {
			title: repoName + dirtyIcon,
			match: alfredMatcher(repoName) + " " + alfredMatcher(repoID),
			icon: { path: iconpath },
			arg: localRepoFilePath,
			uid: repoID,
		};
	}) });
