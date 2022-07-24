#!/usr/bin/env osascript -l JavaScript

function run () {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function finderSelection () {
		const sel = decodeURI(Application("Finder").selection()[0]?.url());
		if (sel === "undefined") return ""; // no selection
		return sel.slice(7);
	}

	const fileExists = (filePath) => Application("Finder").exists(Path(filePath));

	const filePathRegex = /(\/.*)\/(.*\.(\w+))$/;

	function alfredErrorDisplay (text) {
		const item = [{ "title": text }];
		return JSON.stringify({ items: item });
	}

	ObjC.import("Foundation");
	function readFile (path, encoding) {
		if (!encoding) encoding = $.NSUTF8StringEncoding;
		const fm = $.NSFileManager.defaultManager;
		const data = fm.contentsAtPath(path);
		const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
		return ObjC.unwrap(str);
	}

	//------------------------------------------------------------------------------
	let fullPath;
	try {
		fullPath = $.getenv("input");
	} catch (error) {
		fullPath = finderSelection();
		if (!fullPath) return alfredErrorDisplay("No selection");
	}

	const isRegularFile = fullPath.match(filePathRegex);
	if (!isRegularFile) return alfredErrorDisplay("Not a regular file");

	const parentFolder = fullPath.replace(filePathRegex, "$1");
	const isGitRepo = app.doShellScript(`cd "${parentFolder}" ; git rev-parse --git-dir || echo "not a git directory"`).endsWith(".git");
	if (!isGitRepo) return alfredErrorDisplay("Not a git directory");

	const fileName = fullPath.replace(filePathRegex, "$2");
	const ext = fullPath.replace(filePathRegex, "$3");
	const fileIcon = { "type": "fileicon", "path": fullPath };

	let firstItem = true;

	const gitLogArr = app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:"%h;%ad;%s;%an" --date=human "${fullPath}"`)
		.split("\r")
		.map(logLine => {
			const commitHash = logLine.split(";")[0];
			const date = logLine.split(";")[1];
			const safeDate = date.replace(/[/: ]/g, "-");
			const commitMsg = logLine.split(";")[2];
			const author = logLine.split(";")[3];

			// write the file on disk for quicklook and opening
			// dont write file if it already exists, to speed up repeated searches
			const tempPath = `/tmp/${safeDate}_${commitHash}.${ext}`;

			let fileContent;
			if (fileExists(tempPath)) fileContent = readFile(tempPath);
			else fileContent = app.doShellScript(`cd "${parentFolder}" ; git show "${commitHash}:./${fileName}" | tee "${tempPath}"`);
			if (!fileContent) fileContent = "";

			const fileSizeKb = (fileContent.length / 1024).toFixed(2);

			let titleAppendix = "";
			if (firstItem) {
				titleAppendix = "  –  " + fileName;
				firstItem = false;
			}

			return {
				"title": date + titleAppendix,
				"match": fileContent.replace(/\r|[:,;.()/\\{}[\]\-_+"']/g, " ") + ` ${author} ${commitMsg}`,
				"quicklookurl": tempPath,
				"subtitle": `${fileSizeKb} Kb  ▪  ${author}  ▪  ${commitMsg}`,
				"mods": {
					"alt": {
						"arg": commitHash,
						"subtitle": `${commitHash} (⌥: Copy)`
					},
				},
				"icon": fileIcon,
				"arg": tempPath,
			};
		});
	return JSON.stringify({ items: gitLogArr });
}
