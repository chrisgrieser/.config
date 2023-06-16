#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

const volumes = app
	.doShellScript("df -h")
// .doShellScript(`df -h | grep "${vol}" | tr -s " " | cut -d " " -f 2-5 | tr "i." "b," `)
	.split("\r")
	.filter((/** @type {string} */ line) => line.startsWith("/Volumes/"))
	.map((/** @type {string} */ vol) => {
		const info = vol.split(/\s+/)
		const total = info[1];
		const used = info[2];
		const available = info[3];
		const share = info[4];


			// .replaceAll("unavailable", "…") // large volume still loading
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

JSON.stringify({
	rerun: rerunSecs, // seconds (only 0.1 - 5)
	items: volumes,
});
