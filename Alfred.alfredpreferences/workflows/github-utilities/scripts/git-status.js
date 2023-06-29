#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]`]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

/** @return {string|null} */
function finderFrontWindow() {
	try {
		const win = Application("Finder").finderWindows[0];
		return $.NSURL.alloc.initWithString(win.target.url()).fileSystemRepresentation;
	} catch (_error) {
		return null;
	}
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// determine repo & validate it's in a git repo
	const defaultRepo = $.getenv("default_repo").replace(/^~/, app.pathTo("home folder"));
	const repoPath = finderFrontWindow() || defaultRepo;
	try {
		app.doShellScript(`cd "${repoPath}" && git rev-parse --is-inside-work-tree`).startsWith("fatal:");
	} catch (_error) {
		return JSON.stringify({
			items: [{ title: "🚫 Not in Git Repository", valid: false }],
		});
	}

	const gitStatusCommand = "git status --porcelain";
	/** @type AlfredItem[] */
	const unstagesArr = app
		.doShellScript(`cd "${repoPath}" && ${gitStatusCommand}`)
		.split("\r")
		.map((file) => {
			const pathInRepo = file.slice(3);
			const parentFolder = pathInRepo.slice(0, pathInRepo.lastIndexOf("/"));
			const filename = pathInRepo.slice(pathInRepo.lastIndexOf("/") + 1);

			const trackingInfo = file.slice(0, 3);
			const isDeleted = trackingInfo.includes("D");
			const trackingDisplay = trackingInfo
				.replaceAll(" M ", "🟡") // modified
				.replaceAll(" D ", "❌") // deleted
				.replaceAll("?? ", "❇️ ") // untracked (new file)
				.replaceAll("RM ", "🔼✏️  🟡") // staged renamed & unstaged modified
				.replaceAll("MM ", "🔼🟡 🟡") // staged modified & unstaged modified
				.replaceAll("M  ", "🔼🟡") // staged modified
				.replaceAll("D  ", "🔼❌") // staged deleted
				.replaceAll("A  ", "🔼❇️ ") // staged new file
				.replaceAll("R  ", "🔼✏️ "); // staged renamed

			let mode;
			if ([" M ", " D ", "?? ", "RM ", "MM "].includes(trackingInfo)) mode = "stage";
			else if (["M  "].includes(trackingInfo)) mode = "unstage change";
			else if (["A  ", "R  ", "D  "].includes(trackingInfo)) mode = "unstage file";

			return {
				title: `${trackingDisplay}  ${filename}`,
				subtitle: parentFolder,
				match: alfredMatcher(pathInRepo),
				arg: pathInRepo,
				mods: {
					alt: {
						subtitle: isDeleted ? "🚫 Cannot reveal in Finder as file is deleted." : "⌥: Reveal in Finder",
						valid: isDeleted,
						variables: { mode: "reveal" },
					},
					cmd: {
						subtitle: "⌘: Discard Change to File",
						variables: { mode: "reset" },
					},
				},
				variables: { mode: mode },
				uid: pathInRepo, // remember order
			};
		});

	return JSON.stringify({
		skipknowledge: true, // remember order
		variables: { repo: repoPath },
		items: unstagesArr,
	});
}
