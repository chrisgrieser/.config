#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

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
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// determine repo
	const defaultRepo = $.getenv("default_repo").replace(/^~/, app.pathTo("home folder"));
	const filepath = finderFrontWindow() || defaultRepo;

	// determine branches
	const branchCommitPairs = {}
	app.doShellScript(`cd "${filepath}" && git branch --verbose`)
		.split("\r")
		.forEach((line) =>{
			const branch = line.split(" ")[1]
			const hash = line.split(" ")[2]
			branchCommitPairs[hash] = branch
		});

	/** @type AlfredItem[] */
	const commitArr = app
		.doShellScript(`cd "${filepath}" && git log --all --format="%h;;%D;;%cr;;%an;;%s"`)
		.split("\r")
		.map((commit) => {
			const parts = commit.split(";;");
			const hash = parts[0];
			const pointer = parts[1]
				.replaceAll("HEAD", "👤")
				.replaceAll("origin", "☁️")
				.replaceAll("->", "⇢")
				.replaceAll("grafted", "✂️")
				.replace(/\b(master|main)\b/g, "Ⓜ️");
			const date = parts[2];
			const author = noDisplayAuthors.includes(parts[3]) ? "" : `<${parts[3]}>`;
			const msg = parts[4];
			const branch = branchCommitPairs[hash];

			return {
				title: `${msg}   ${pointer}`,
				subtitle: `${date}   ${author}`,
				match: alfredMatcher(msg) + author + " " + pointer,
				arg: hash,
				mods: {
					cmd: {
						arg: branch,
						valid: branch !== undefined,
						subtitle: branch
							? "⌘: Checkout Branch pointing to this commit"
							: "🚫 No Branch pointing to this commit.",
					},
					alt: {
						arg: hash,
						subtitle: `⌥: Copy Hash – ${hash}`,
					},
				},
			};
		});

	return JSON.stringify({ items: commitArr });
}
