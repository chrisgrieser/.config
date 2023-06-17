#!/usr/bin/env osascript -l JavaScript

const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

let rerunSecs = 5;
const volumes = app
	.doShellScript("df -h")
	.split("\r")
	.filter((/** @type {string} */ line) => line.includes(" /Volumes/"))
	.map((/** @type {string} */ vol) => {
		// quicker reruns when volume stats unavailable
		if (vol.includes("unavailable")) rerunSecs = 0.5;

		const info = vol.split(/\s+/).map((value) => {
			return value.replaceAll("unavailable", "…").replaceAll("Gi", "Gb");
		});

		const total = info[1];
		const used = info[2];
		const available = info[3];
		const share = info[4];
		const path = info.slice(8).join(" ");
		const name = path.replace("/Volumes/", "");

		const spaceInfo = `Total: ${total}   Available: ${available}   Used: ${used} (${share})`;
		return {
			title: name,
			subtitle: spaceInfo,
			arg: path,
		};
	});

// No Volume found
if (volumes.length === 0) {
	volumes.push({
		title: "No mounted volume recognized.",
		subtitle: "⎋ to abort",
		valid: false,
	});
	rerunSecs = 0.5; // quicker reruns when no volume found
}

JSON.stringify({
	rerun: rerunSecs, // seconds (only 0.1 - 5)
	items: volumes,
});
