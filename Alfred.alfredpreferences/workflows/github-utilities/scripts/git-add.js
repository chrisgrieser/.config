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
		.filter(line => line.startsWith("??") || line.startsWith(" ")) // unstaged files/changes
		.map((file) => {
			const pathInRepo = file.slice(3);
			const parentFolder = pathInRepo.slice(0, pathInRepo.lastIndexOf("/"));
			const filename = pathInRepo.slice(pathInRepo.lastIndexOf("/") + 1);
			const trackingInfo = file.slice(0, 2)
				.replaceAll(" M", "🟡 M")
				.replaceAll("D", "❌ D")
				.replaceAll("??", "❇️ ??")

			return {
				title: `${trackingInfo}   ${filename}`,
				subtitle: parentFolder,
				match: alfredMatcher(filename) + alfredMatcher(parentFolder),
				arg: pathInRepo,
			};
		});

	return JSON.stringify({
		variables: { repo: repoPath },
		items: unstagesArr,
	});
}
