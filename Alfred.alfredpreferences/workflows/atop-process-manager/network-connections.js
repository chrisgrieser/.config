#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

let rerunSecs = parseFloat($.getenv("rerun_s_network")) || 2.5;
if (rerunSecs < 0.1) rerunSecs = 0.1;
else if (rerunSecs > 5) rerunSecs = 5;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	/** @type AlfredItem[] */
	const connections = app
		.doShellScript("nettop -P -L1 -J bytes_in,bytes_out")
		.split("\r")
		.slice(1) // remove header
		.map((connection) => {
			const info = connection.split(","); // `nettop` output comma-separated due to `-L`
			const name = info[0].split(".")[0];
			const id = info[0].split(".")[1];
			const downKb = parseInt(info[1]) / 1024;
			const upKb = parseInt(info[2]) / 1024;
			const down = downKb > 1024 ? `${downKb / 1024}Mb` : `${downKb}Kb`;
			const up = upKb > 1024 ? `${upKb / 1024}Mb` : `${upKb}Kb`;

			return {
				title: name,
				subtitle: `🔻 ${down}   🔺${up}`,
				valid: false,
				uid: id, // during rerun remembers selection, but does not affect sorting
				down:downKb, // for sorting, not Alfred
			};
		})
		.sort((a, b) => b.down - a.down) // sort by downloads

	return JSON.stringify({
		skipknowledge: true, // during rerun remembers selection, but does not affect sorting
		rerun: rerunSecs,
		items: connections,
	});
}
