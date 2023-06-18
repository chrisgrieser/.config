#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const cpuThreshhold = 0.2;
const memoryThreshhold = 0.2;
const availableMemory = parseInt(app.doShellScript("system_profiler SPHardwareDataType | grep 'Memory:' | awk '{print $2}'")) * 1024;

const processAppName = {
	Alfred: "Alfred 5",
	CleanShot: "CleanShot X",
	Brave: "Brave Browser",
	neovide: "Neovide",
	espanso: "Espanso",
	alacritty: "Alacritty",
	"wezterm-gui": "WezTerm",
};

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let rerunSecs = parseFloat($.getenv("rerun_s"));
	if (!rerunSecs) {
		return JSON.stringify({ items: [{ title: "⚠️ Invalid refresh value", valid: false }] });
	}
	if (rerunSecs <= 0) rerunSecs = 0.2;
	else if (rerunSecs > 5) rerunSecs = 5;

	const apps = app.doShellScript("ls /Applications/");
	const processes = app
		.doShellScript("ps rcAo 'pid=,%cpu=,%mem=,command='")
		.split("\r")
		.map((/** @type {string} */ processInfo) => {
			const info = processInfo.trim().split(/\s+/);
			const pid = info[0];
			let cpu = info[1];
			let memory = (parseInt(info[2]) / 100 * availableMemory).toFixed(1).toString();
			const processName = info[3];

			if (processName === "<defunct>") return {};

			const appName = processAppName[processName];
			const displayTitle = appName ? `${appName} (${processName})` : processName;
			cpu = parseFloat(cpu) > cpuThreshhold ? cpu + "%" : "";
			memory = parseFloat(memory) > memoryThreshhold ? memory : "";
			const isApp = apps.includes(processName);
			const icon = isApp ? { type: "fileicon", path: `/Applications/${appName}.app` } : {};

			return {
				title: displayTitle,
				subtitle: [cpu, memory].join("    "),
				icon: icon,
				arg: pid,
				mods: {
					ctrl: { variables: { mode: "killall" } },
					cmd: { variables: { mode: "force kill" } },
					alt: {
						valid: isApp,
						subtitle: isApp ? "⌥: Restart App" : "⌥: ⛔ Not an app",
						variables: { mode: "restart app" },
					},
				},
			};
		});

	return JSON.stringify({
		variables: { mode: "kill" },
		rerun: rerunSecs,
		items: processes,
	});
}
