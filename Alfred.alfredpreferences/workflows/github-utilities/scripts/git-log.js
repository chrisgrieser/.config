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

const noDisplayAuthors = $.getenv("no_display_authors")
	.split(",")
	.map((t) => t.trim());

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// determine repo
	const defaultRepo = $.getenv("default_repo").replace(/^~/, app.pathTo("home folder"));
	const repoPath = finderFrontWindow() || defaultRepo;

	// validate it's in a git repo
	try {
		app.doShellScript(`cd "${repoPath}" && git rev-parse --is-inside-work-tree`).startsWith("fatal:");
	} catch (_error) {
		return JSON.stringify({
			items: [{ title: "🚫 Not in Git Repository", valid: false }],
		});
	}

	// determine branches
	const branchCommitPairs = {};
	const branches = app.doShellScript(`cd "${repoPath}" && git branch --verbose`).split("\r");
	for (const line of branches) {
		const branch = line.split(" ")[1];
		const hash = line.split(" ")[2];
		branchCommitPairs[hash] = branch;
	}

	// https://stackoverflow.com/questions/3701404/how-to-list-all-commits-that-changed-a-specific-file
	const gitLogCommand = 'git log --all --format="%h;;%D;;%cr;;%an;;%s"';

	/** @type AlfredItem[] */
	const commitArr = app
		.doShellScript(`cd "${repoPath}" && ${gitLogCommand}`)
		.split("\r")
		.map((commit) => {
			const parts = commit.split(";;");
			const hash = parts[0];
			const pointer = parts[1];
			const pointerDisplay = pointer
				.replaceAll("HEAD", "👤")
				.replaceAll("origin", "☁️")
				.replaceAll("->", "⇢")
				.replaceAll("grafted", "✂️")
				.replace(/\b(master|main)\b/g, "Ⓜ️");
			const date = parts[2];
			const author = noDisplayAuthors.includes(parts[3]) ? "" : `<${parts[3]}>`;
			const msg = parts[4];
			const branch = branchCommitPairs[hash];

			// when branch is on commit, checkout branch, otherwise use hash
			const hashOrBranch = branch || hash;

			return {
				title: `${msg}   ${pointerDisplay}`,
				subtitle: `${date}   ${author}`,
				match: alfredMatcher(msg) + author + " " + pointer,
				arg: hashOrBranch,
				variables: { mode: "checkout" },
				mods: {
					cmd: {
						arg: hash,
						subtitle: "⌘: Reset (hard) to this commit",
						variables: { mode: "Reset Hard" },
					},
					alt: {
						arg: hash,
						subtitle: `⌥: Copy Hash    ${hash}`,
						variables: { mode: "Copy Hash" },
					},
				},
			};
		});

	return JSON.stringify({ items: commitArr });
}
