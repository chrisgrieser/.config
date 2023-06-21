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

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const defaultRepo = $.getenv("default_repo").replace(/^~/, app.pathTo("home folder"));
	const filepath = finderFrontWindow() || defaultRepo;

	/** @type AlfredItem[] */
	const commitArr = app
		.doShellScript(`cd "${filepath}" && git log --all --format="%h;;%d;;%cr;;%s"`)
		.split("\r")
		.map((commit) => {
			const parts = commit.split(";;");
			const hash = parts[0];
			const pointer = parts[1]
				.replaceAll("HEAD", "👤")
				.replaceAll("origin", "☁️")
				.replaceAll("->", "⇢")
				.replaceAll("grafted", "✂️");
			const date = parts[2];
			const msg = parts.slice(3).join(" ");
			return {
				title: msg + pointer,
				subtitle: date,
				match: alfredMatcher(pointer) + " " + alfredMatcher(msg),
				arg: hash,
				mods: {
					alt: {
						arg: hash,
						subtitle: `⌥: Copy Hash – ${hash}`,
					},
				},
			};
		});

	// direct return
	return JSON.stringify({
		skipknowledge: true, // do not let Alfred sort the commits, since they ordered by date already
		items: commitArr,
	});
}
