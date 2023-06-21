#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

function finderFrontWindow(){
	const posixPath = (/** @type {Object} */ finderWin) => $.NSURL.alloc.initWithString(finderWin.target.url()).fileSystemRepresentation;
	return posixPath(Application("Finder").finderWindows[0]);
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {

	const filepath = finderFrontWindow();
	console.log("filepath:", filepath);

	/** @type AlfredItem[] */
	const commitArr = app
		.doShellScript(`cd "${filepath}" && git log --oneline`)
		.split("\r")
		.map((commit) => {
			const hash = commit.split(" ")[0];
			const msg = commit.split(" ").slice(1).join(" ");
			return {
				title: msg,
				subtitle: hash,
				match: alfredMatcher(hash) + " " + alfredMatcher(msg),
				arg: hash,
			};
		});

	// direct return
	return JSON.stringify({
		skipknowledge: true, // do not let Alfred sort the commits, since they ordered by date already
		items: commitArr,
	});
}
