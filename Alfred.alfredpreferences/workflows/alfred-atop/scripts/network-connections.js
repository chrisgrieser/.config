#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const rerunSecs = Number.parseFloat($.getenv("rerun_s_network"));
	const installedApps = app
		.doShellScript("ls /Applications/")
		.split("\r")
		.filter((line) => line.endsWith(".app"));

	/** @type {AlfredItem|{}[]} */
	const connections = app
		.doShellScript("nettop -d -P -L1 -J bytes_in,bytes_out")
		.split("\r")
		.slice(1) // remove header
		.filter(connection => !(connection.endsWith("0,0,") || connection.startsWith(".")))
		.map((connection) => {
			const info = connection.split(","); // `nettop` output comma-separated due to `-L`
			const name = info[0].replace(/\.\d+?$/, "").replace(/ H(elper)?$/, "");

			const downKb = Number.parseInt(info[1]) / 1024;
			const upKb = Number.parseInt(info[2]) / 1024;
			const down = downKb > 1024 ? `${(downKb / 1024).toFixed(1)}M` : `${downKb.toFixed(0)}K`;
			const up = upKb > 1024 ? `${(upKb / 1024).toFixed(1)}M` : `${upKb.toFixed(0)}K`;

			const isApp = installedApps.includes(`${name}.app`);
			const icon = isApp ? { type: "fileicon", path: `/Applications/${name}.app` } : {};

			return {
				title: name,
				subtitle: `🔽 ${down}   🔺${up}`,
				icon: icon,
				uid: name,
				valid: false, // no action available
				down: downKb, // for sorting, not Alfred
			};
		})
		.sort((a, b) => b.down - a.down); // sort by downloads

	return JSON.stringify({
		skipknowledge: true, // during rerun remembers selection, but does not affect sorting
		rerun: rerunSecs,
		items: connections,
	});
}
