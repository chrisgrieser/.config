#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;

const notToDisplay = ["Macintosh HD", "Samsung SSD 1TB", "GoogleDrive", "Recovery"];

//──────────────────────────────────────────────────────────────────────────────

const volumes = app
	.doShellScript("ls /Volumes/")
	.split("\r")
	.map((/** @type {string} */ vol) => {
		if (notToDisplay.includes(vol)) return {};
		const space = app.doShellScript(`df -h | grep "${vol}" | tr -s " " | cut -d " " -f 2-5 | tr "i." "b," `).split(" ");
		const spaceInfo = `Total: ${space[0]}   Available: ${space[2]}   Used: ${space[1]} (${space[3]})`;
		return {
			title: "📂 " + vol,
			subtitle: spaceInfo,
			arg: "/Volumes/" + vol,
		};
	});

let rerunSecs = 5;

if (volumes.length === 0) {
	volumes.push({
		title: "No mounted volume recognized.",
		subtitle: "Press [Esc] to abort.",
		arg: "no volume",
	});
	rerunSecs = 1; // quicker reruns when no volume found
}

/** @type function {} */
JSON.stringify({
	rerun: rerunSecs, // seconds (only 0.1 - 5)
	items: volumes,
});
// JSON.stringify(out);
