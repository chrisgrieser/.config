#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const soundsArr = app
		.doShellScript(
			// WARN codespell fixes ".caf" to ".calf"
			'find "/System/Library/Sounds" "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds" -name "*.aif" -or -name "*.aiff" -or -name "*.caf" -not -path "*telephony*"',
		)
		.split("\r")
		.map((path) => {
			const filename = path.split("/").pop().split(".")[0];
			return {
				title: filename,
				arg: path,
			};
		});
	return JSON.stringify({ items: soundsArr });
}
