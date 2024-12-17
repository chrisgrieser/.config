#!/usr/bin/env osascript -l JavaScript
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// special volumes to ignore
const ignoreVolumes = ["Recovery"];

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let rerunSecs = 4; // slow reruns as default

	/** @type AlfredItem[] */
	const volumes = app
		.doShellScript("df -HY") // -H: human readable sizes (base10), -Y: filesystem format
		.split("\r")
		.reduce((/** @type {AlfredItem[]} */ volumes, line) => {
			if (!line.includes(" /Volumes/")) return volumes;
			// quicker reruns when volume stats unavailable
			if (line.includes("unavailable")) rerunSecs = 0.5;

			const info = line
				.split(/\s+/)
				.map((value) => value.replaceAll("unavailable", "…").replace(/(\d[GTMk]$)/, "$1b"));

			const [_, format, total, used, available, share] = info;
			const path = info.slice(9).join(" ");
			const name = path.replace("/Volumes/", "");

			if (ignoreVolumes.includes(name)) return volumes;

			const subtitle = `『${format}』   Total: ${total}   Available: ${available}   Used: ${used} (${share})`;
			volumes.push({
				title: name,
				uid: path, // during rerun remembers selection, but does not affect sorting
				subtitle: subtitle,
				arg: path,
			});
			return volumes;
		}, []);

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
