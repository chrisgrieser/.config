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

	let FULL_PATH;
	try {
		FULL_PATH = $.getenv("input");
	} catch (error) {
		FULL_PATH = finderSelection();
		if (!FULL_PATH) return alfredErrorDisplay("No selection");
	}

	const isRegularFile = FULL_PATH.match(filePathRegex);
	if (!isRegularFile) return alfredErrorDisplay("Not a regular file");

	const PARENT_FOLDER = FULL_PATH.replace(filePathRegex, "$1");
	const isGitRepo = app.doShellScript(`cd "${PARENT_FOLDER}" ; git rev-parse --git-dir || echo "not a git directory"`).endsWith(".git");
	if (!isGitRepo) return alfredErrorDisplay("Not a git directory");

	const FILE_NAME = FULL_PATH.replace(filePathRegex, "$2");
	const safeFileName = FILE_NAME.replace(/[/: .]/g, "-");
	const EXT = FULL_PATH.replace(filePathRegex, "$3");
	const FILE_ICON = { "type": "fileicon", "path": FULL_PATH };
	const TEMP_DIR = "/tmp/" + safeFileName;

	//------------------------------------------------------------------------------

	const FIRST_RUN = query === "";
	let FIRST_ITEM = true;
	let historyMatches;
	let extraOptions = "";
	if (FIRST_RUN) extraOptions = ";%ad;%s;%an";

	// write versions into temporary directory
	const logLines = app.doShellScript(`cd "${PARENT_FOLDER}" ; git log --pretty=format:"%h${extraOptions}" --date=human "${FULL_PATH}"`)
		.split("\r");
	app.doShellScript(`mkdir -p ${TEMP_DIR}`);
	logLines.forEach(line => {
		const commitHash = line.split(";")[0];
		const filePath = `${TEMP_DIR}/${commitHash}.${EXT}`;
		if (!fileExists(filePath)) {
			app.doShellScript(`cd "${PARENT_FOLDER}" ; git show "${commitHash}:./${FILE_NAME}" > "${filePath}"`);
		}
	});

	// show all versions of file with commit message, author. Sorted by commit date.
	if (FIRST_RUN) {
		historyMatches = logLines.map(line => {
			const lineParts = line.split(";");
			const commitHash = lineParts[0];
			const displayDate = lineParts[1]; // results from `extraOptions`
			const commitMsg = lineParts[2]; //   ^
			const author = lineParts[3]; //      ^
			const filePath =`${TEMP_DIR}/${commitHash}.${EXT}`;

			const subtitle = `${commitMsg}  ▪︎  ${author}`;

			let appendix = "";
			if (FIRST_ITEM) {
				appendix = "  ▪︎  " + FILE_NAME;
				FIRST_ITEM = false;
			}

			return {
				"title": displayDate + appendix,
				"subtitle": subtitle,
				"quicklookurl": filePath,
				"mods": {
					"cmd": { "arg": `${filePath};${FULL_PATH}` }, // old;new file for diff view
					"alt": {
						"arg": commitHash,
						"subtitle": `${commitHash}    (⌥: Copy)`
					},
				},
				"icon": FILE_ICON,
				"arg": `${filePath}`,
			};

		});

	// search versions with ripgrep & display git commit info for matched versions
	} else {
		historyMatches = app.doShellScript(`export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; cd "${TEMP_DIR}" ; rg --max-count=1 --line-number --smart-case "${query}"`)
			.split("\r")
			.map(rgMatch => {
				const commitHash = rgMatch.split(".")[0];
				const displayDate = app.doShellScript(`cd "${PARENT_FOLDER}" ; git show -s --format=%ad --date=human ${commitHash}`);
				const date = app.doShellScript(`cd "${PARENT_FOLDER}" ; git show -s --format=%ad ${commitHash}`);
				const lineParts = rgMatch.split(":");
				const file = lineParts[0];
				const line = lineParts[1];
				const firstMatch = lineParts[2].trim();
				const filePath =`${TEMP_DIR}/${file}`;

				let appendix = "";
				if (FIRST_ITEM) {
					appendix = "  ▪︎  " + FILE_NAME;
					FIRST_ITEM = false;
				}

				return {
					"date": date,
					"title": displayDate + appendix,
					"subtitle": firstMatch,
					"quicklookurl": filePath,
					"mods": {
						"cmd": { "arg": `${filePath};${FULL_PATH}` }, // old;new file for diff view
						"alt": {
							"arg": commitHash,
							"subtitle": `${commitHash}    (⌥: Copy)`
						},
					},
					"icon": FILE_ICON,
					"arg": `${filePath}:${line}`,
				};

			})
			// sort not via ripgrep, since sorting in ripgrep makes it run single-threaded (= slower)
			.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
	}

	return JSON.stringify({ items: historyMatches });
}
