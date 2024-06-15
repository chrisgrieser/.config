#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function camelCaseMatch(str) {
	const subwords = str.replace(/[-_./]/g, " ");
	const fullword = str.replace(/[-_./]/g, "");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [subwords, camelCaseSeparated, fullword, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const shellCmd =
		'find "/System/Library/Sounds" "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds" -name "*.aif" -or -name "*.aiff" -or -name "*.caf" -not -path "*telephony*"';

	/** @type AlfredItem[] */
	const soundsArr = app
		.doShellScript(shellCmd)
		.split("\r")
		.map((path) => {
			const filename = path.split("/").pop()?.split(".")[0] || "unknown";
			return {
				title: filename,
				match: camelCaseMatch(filename),
				arg: path,
			};
		});

	return JSON.stringify({
		items: soundsArr,
		cache: { loosereload: true, seconds: 3600 },
	});
}
