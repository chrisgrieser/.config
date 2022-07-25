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


	// write versions into temporary directory
	app.doShellScript(`mkdir -p ${tempDir}`);
	app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:%h "${fullPath}"`)
		.split("\r")
		.forEach(commitHash => {
			const tempPath = `${tempDir}/${commitHash}.${ext}`;
			if (fileExists(tempPath)) {
				app.doShellScript(`touch "${tempPath}"`); // to update access date, which is used by rg for sorting
			} else {
				app.doShellScript(`cd "${parentFolder}" ; git show "${commitHash}:./${fileName}" > "${tempPath}"`);
			}
		});

	let firstItem = true;

	// search versions with ripgrep & display git commit info for matched versions
	const ripgrepMatches = app.doShellScript(`export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; cd "${tempDir}" ; rg --sort=accessed --files-with-matches --ignore-case "${query}"`)
		.split("\r")
		.map(file => {
			const commitHash = file.replace(/(\w+)\.\w+/, "$1");
			const logline = app.doShellScript(`cd "${parentFolder}" ; git show -s --format="%ad;%s;%an" --date=human ${commitHash}`);
			const date = logline.split(";")[0];
			const commitMsg = logline.split(";")[1];
			const author = logline.split(";")[2];

			let match = "";
			let line = "";
			if (query) {
				const firstMatch = app.doShellScript(`export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; cd "${tempDir}" ; rg --max-count=1 --line-number "${query}" "${file}"`);
				const tempArr = firstMatch.split(":");
				tempArr.shift();
				match = tempArr.join("").trim();
				line = ":" + firstMatch.split(":")[0];
			}

			let appendix = "";
			if (firstItem) {
				appendix = "  ▪︎  " + fileName;
				firstItem = false;
			}

			return {
				"title": date + appendix,
				"subtitle": match,
				"mods": {
					"cmd": { "arg": `${tempDir}/${file};${fullPath}` },
					"alt": {
						"arg": commitHash,
						"subtitle": `${commitHash} (⌥: Copy)`
					},
					"ctrl": {
						"subtitle": `${commitMsg}  ▪︎  ${author}`,
						"valid": false
					},
				},
				"icon": fileIcon,
				"arg": `${tempDir}/${file}${line}`,
			};
		});
	return JSON.stringify({ items: ripgrepMatches });
}
