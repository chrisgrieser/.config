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

	const filePathRegex = /(\/.*)\/(.*\.(\w+))$/;

	function alfredErrorDisplay (text) {
		const item = [{ "title": text }];
		return JSON.stringify({ items: item });
	}

	function padLeft (str, target) {
		const diff = target - str.length;
		if (diff > 0) {
			for (let i = 1; i <= diff; i++) {
				str += " ";
			}
		}
		return str;
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
	const FILE_ICON = { "type": "fileicon", "path": FULL_PATH };

	//------------------------------------------------------------------------------

	const FIRST_RUN = query === "";
	let FIRST_ITEM = true;
	let historyMatches;
	let logLines;
	if (FIRST_RUN) {
		logLines = app.doShellScript(`cd "${PARENT_FOLDER}" ; git log --pretty=format:"%h;%ah;%s;%an" --numstat "${FULL_PATH}"`)
			.split("\r\r")
			.map(commit => commit.replaceAll("\r", ";"));
	} else {
		logLines = app.doShellScript(`cd "${PARENT_FOLDER}" ; git log --pretty=format:%h "${FULL_PATH}"`)
			.split("\r");
	}

	// show all versions of file with commit message, author. Sorted by commit date.
	if (FIRST_RUN) {
		historyMatches = logLines.map(line => {
			const commitHash = line.split(";")[0];
			const displayDate = line.split(";")[1]; // results from `extraOptions`
			const commitMsg = line.split(";")[2]; //             ^
			const author = line.split(";")[3]; //                ^
			const numstat = line.split(";")[4].match(/\d+/g); // ^

			const changes = Number(numstat[0]) + Number(numstat[1]);
			const displayChanges = padLeft(changes.toString(), 3);

			const subtitle = `${displayChanges}  ▪︎  ${commitMsg}  ▪︎  ${author}`;

			let appendix = "";
			if (FIRST_ITEM) {
				appendix = "  ▪︎  " + FILE_NAME;
				FIRST_ITEM = false;
			}

			return {
				"title": displayDate + appendix,
				"subtitle": subtitle,
				"mods": {
					"alt": {
						"arg": commitHash,
						"subtitle": `${commitHash}    (⌥: Copy)`
					},
				},
				"icon": FILE_ICON,
				"arg": `${commitHash};${FULL_PATH};0`,
			};

		});

	// search patches for change (git log -G) & display git commit info for matched versions
	} else {
		historyMatches = app.doShellScript(`cd "${PARENT_FOLDER}" ; git log -G"${query}" --regexp-ignore-case --pretty=%h -- "${FULL_PATH}"`)
			.split("\r")
			.map(commitHash => {
				const displayDate = app.doShellScript(`cd "${PARENT_FOLDER}" ; git show -s --format=%ah ${commitHash}`);
				const grepMatch = app.doShellScript(`cd "${PARENT_FOLDER}" ; git show "${commitHash}:./${FILE_NAME}" | grep "${query}" --max-count=1 --ignore-case --line-number || true`);
				let line;
				let firstMatch;
				if (grepMatch) {
					line = grepMatch.split(":")[0];
					firstMatch = grepMatch.split(":")[1].trim();
				} else {
					firstMatch = `['${query}' removed in this commit]`;
					line = "0";
				}

				let appendix = "";
				if (FIRST_ITEM) {
					appendix = "  ▪︎  " + FILE_NAME;
					FIRST_ITEM = false;
				}

				return {
					"title": displayDate + appendix,
					"subtitle": firstMatch,
					"mods": {
						"alt": {
							"arg": commitHash,
							"subtitle": `${commitHash}    (⌥: Copy)`
						},
					},
					"icon": FILE_ICON,
					"arg": `${commitHash};${FULL_PATH};${line}`,
				};

			});
	}

	return JSON.stringify({ items: historyMatches });
}
