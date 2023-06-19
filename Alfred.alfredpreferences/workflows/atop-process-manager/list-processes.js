#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

// common apps where process name and app name are different
const processAppName = {
	Alfred: "Alfred 5",
	CleanShot: "CleanShot X",
	neovide: "Neovide",
	espanso: "Espanso",
	alacritty: "Alacritty",
	"wezterm-gui": "WezTerm",
	bird: "iCloud Sync",
};

// common apps not located in /Applications/
const appFilePaths = {
	Finder: "/System/Library/CoreServices/Finder.app",
	"Alfred Preferences": "/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app",
};

//──────────────────────────────────────────────────────────────────────────────

let rerunSecs = parseFloat($.getenv("rerun_s_processes")) || 2.5;
if (rerunSecs < 0.1) rerunSecs = 0.1;
else if (rerunSecs > 5) rerunSecs = 5;

const cpuThresholdPercent = parseFloat($.getenv("cpu_threshold_percent")) || 0.5;
const memoryThresholdMb = parseFloat($.getenv("memory_threshold_mb")) || 10;
const sort = $.getenv("sort_key") === "Memory" ? "m" : "r";

const apps = app
	.doShellScript("ls /Applications/")
	.split("\r")
	.filter((line) => line.endsWith(".app"));

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const processes = app
		.doShellScript(`ps ${sort}cAo 'pid=,%cpu=,rss=,ruser=,command='`)
		.split("\r")
		.map((/** @type {string} */ processInfo) => {
			const info = processInfo.trim().split(/ +/);
			const processName = info.slice(4).join(" "); // command name can contain spaces, therefore last
			if (processName === "<defunct>") return {};

			const pid = info[0];
			const isRootUser = info[3] === "root" ? " ⭕" : "";
			const appName = processAppName[processName] || processName;
			const displayTitle = appName !== processName ? `${processName} [${appName}]` : processName;
			let cpu = info[1];
			cpu = parseFloat(cpu) > cpuThresholdPercent ? cpu + "%    " : "";
			let memory = (parseInt(info[2]) / 1024).toFixed(0).toString(); // real memory
			memory = parseInt(memory) > memoryThresholdMb ? memory + "Mb" : "";

			// icon
			const isApp = apps.includes(`${appName}.app`) || appFilePaths[appName];
			let icon = {};
			if (isApp) {
				const path = appFilePaths[appName] || `/Applications/${appName}.app`;
				icon = { type: "fileicon", path: path };
			}

			return {
				title: displayTitle + isRootUser,
				subtitle: cpu + memory + " ", // trailing space to ensure same height of all items
				icon: icon,
				arg: pid,
				mods: {
					ctrl: { variables: { mode: "killall" } },
					cmd: { variables: { mode: "force kill" } },
					shift: {
						valid: isApp,
						subtitle: isApp ? "⇧: Restart App" : "⇧: ⛔ Not an app",
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
