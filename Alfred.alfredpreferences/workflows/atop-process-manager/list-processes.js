#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// common apps where process name and app name are different
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

let rerunSecs = parseFloat($.getenv("rerun_s")) || 2.5;
if (rerunSecs < 0.1) rerunSecs = 0.1;
else if (rerunSecs > 5) rerunSecs = 5;

const cpuThresholdPercent = parseFloat($.getenv("cpu_threshold_percent")) || 0.5;
const memoryThresholdMb = parseFloat($.getenv("memory_threshold_mb")) || 50;

const apps = app.doShellScript("ls /Applications/");

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const processes = app
		.doShellScript("ps rcAo 'pid=,%cpu=,%mem=,command='")
		.split("\r")
		.map((/** @type {string} */ processInfo) => {
			const info = processInfo.trim().split(/\s+/);
			const processName = info[3];
			if (processName === "<defunct>") return {};

			const pid = info[0];
			let cpu = info[1];
			let memory = parseInt(info[2]) / 1024;

			let memory = ((parseFloat(info[2]) / 100) * availableMemoryMb).toFixed(0).toString();

			const appName = processAppName[processName] || processName;
			const isApp = apps.includes(appName);
			const displayTitle = appName !== processName ? `${processName} (${appName})` : processName;
			const icon = isApp ? { type: "fileicon", path: `/Applications/${appName}.app` } : {};
			const separator = "    ";
			cpu = parseFloat(cpu) > cpuThresholdPercent ? cpu + "%" + separator : "";
			memory = parseInt(memory) > memoryThresholdMb ? memory + "Mb" : "";

			/** @type AlfredItem */
			const alfredItem = {
				title: displayTitle,
				subtitle: cpu + memory + " ", // trailing space to ensure same height of all items
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
			return alfredItem;
		});

	return JSON.stringify({
		variables: { mode: "kill" },
		rerun: rerunSecs,
		items: processes,
	});
}
