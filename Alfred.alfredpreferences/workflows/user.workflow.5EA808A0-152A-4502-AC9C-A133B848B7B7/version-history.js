#!/usr/bin/env osascript -l JavaScript

function run (argv) {
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
	const query = argv.join("");

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
	const safeFileName = fileName.replace(/[/: .]/g, "-");
	const ext = fullPath.replace(filePathRegex, "$3");
	const fileIcon = { "type": "fileicon", "path": fullPath };
	const tempDir = `/tmp/${safeFileName}`;

	app.doShellScript(`mkdir -p ${tempDir}`);

	app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:"%h;%ad" --date=human "${fullPath}"`)
		.split("\r")
		.forEach(logLine => {
			const commitHash = logLine.split(";")[0];
			const date = logLine.split(";")[1];
			const safeDate = date.replace(/[/: ]/g, "-");

			// write the file on disk for quicklook and opening
			// dont write file if it already exists, to speed up repeated searches
			const tempPath = `${tempDir}/${safeDate}_${commitHash}.${ext}`;
			if (!fileExists(tempPath)) app.doShellScript(`cd "${parentFolder}" ; git show "${commitHash}:./${fileName}" > "${tempPath}"`);
		});

	const ripgrepMatches = app.doShellScript(`export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; cd "${tempDir}" ; rg --hidden --files-with-matches "${query}"`)
		.split("\r")
		.map(line => {
			const commitHash = line.replace(/.*_(\w+)\.\w+/, "$1");
			const date = line.replace(/(.*)_.*/, "$1");
			// const safeDate = date.replace(/[/: ]/g, "-");
			// const commitMsg = line.split(";")[2];
			// const author = line.split(";")[3];

			return {
				"title": date,
				"subtitle": commitHash,
				"mods": {
					"alt": {
						"arg": commitHash,
						"subtitle": `${commitHash} (⌥: Copy)`
					},
				},
				"icon": fileIcon,
				"arg": commitHash,
			};
		});
	return JSON.stringify({ items: ripgrepMatches });
}
