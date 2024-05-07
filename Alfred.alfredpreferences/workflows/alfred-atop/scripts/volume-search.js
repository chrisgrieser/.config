#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let rerunSecs = 4; // slow reruns as default

	/** @type AlfredItem[] */
	const volumes = app
		.doShellScript("df -HY") // -H: human readable sizes (base10), -Y: filesystem format
		.split("\r")
		.filter((line) => line.includes(" /Volumes/"))
		.map((vol) => {
			// quicker reruns when volume stats unavailable
			if (vol.includes("unavailable")) rerunSecs = 0.5;

			const info = vol
				.split(/\s+/)
				.map((value) => value.replaceAll("unavailable", "…").replace(/(\d[GTMk]$)/, "$1b"));

			const [_, format, total, used, available, share] = info;
			const path = info.slice(9).join(" ");
			const name = path.replace("/Volumes/", "");

			const subtitle = `『${format}』   Total: ${total}   Available: ${available}   Used: ${used} (${share})`;
			return {
				title: name,
				uid: path, // during rerun remembers selection, but does not affect sorting
				subtitle: subtitle,
				arg: path,
			};
		});

	// No Volume found
	if (volumes.length === 0) {
		rerunSecs = 1; // quicker reruns when no volume found

		// simple spinner, which just selects by random
		const spinnerAll = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
		const spinner = spinnerAll[Math.floor(Math.random() * spinnerAll.length)];

		volumes.push({
			title: `No mounted volume recognized.  ${spinner}`,
			subtitle: `(rescans every ${rerunSecs}s)`,
			valid: false,
		});
	}

	return JSON.stringify({
		skipknowledge: true, // during rerun remembers selection, but does not affect sorting
		rerun: rerunSecs, // seconds (only 0.1 - 5)
		items: volumes,
	});
}
