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
	"Brave Browser Helper": "Brave Browser",
	"Brave Browser Helper (Renderer)": "Brave Browser",
	"Brave Browser Helper (GPU)": "Brave Browser",
	"Discord Helper": "Discord",
	"Discord Helper (Renderer)": "Discord",
	"Discord Helper (GPU)": "Discord",
	"Slack Helper": "Slack",
	"Slack Helper (Renderer)": "Slack",
	"Slack Helper (GPU)": "Slack",
	"Obsidian Helper": "Obsidian",
	"Obsidian Helper (Renderer)": "Obsidian",
	"Obsidian Helper (GPU)": "Obsidian",
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
	const parentProcs = {}

	const processes = app
		.doShellScript(`ps ${sort}cAo 'pid=,ppid=,%cpu=,rss=,ruser=,command='`)
		.split("\r")
		.map((/** @type {string} */ processInfo) => {
			const info = processInfo.trim().split(/ +/);
			const processName = info.slice(5).join(" "); // command name can contain spaces, therefore last
			if (processName === "<defunct>") return {};

			const pid = info[0];
			const ppid = info[1];
			let parentName = "";
			const parentNotLaunchD = parseInt(ppid) > 2
			if (parseInt(ppid) > 2) {
				try {
					parentName = ;
					parentProcs[ppid] = parentName
				} catch (_error) {}
			}
			if (parentName) parentName += " ";

			const isRootUser = info[4] === "root" ? " ⭕" : "";
			const appName = processAppName[processName] || processName;
			const displayTitle =
				appName !== processName && !processName.includes("Helper") ? `${processName} [${appName}]` : processName;
			let memory = (parseInt(info[3]) / 1024).toFixed(0).toString(); // real memory
			memory = parseInt(memory) > memoryThresholdMb ? memory + "Mb    " : "";
			let cpu = info[2];
			cpu = parseFloat(cpu) > cpuThresholdPercent ? cpu + "%    " : "";

			// icon
			const isApp = apps.includes(`${appName}.app`) || appFilePaths[appName];
			let icon = {};
			if (isApp) {
				const path = appFilePaths[appName] || `/Applications/${appName}.app`;
				icon = { type: "fileicon", path: path };
			}

			return {
				title: displayTitle + isRootUser,
				subtitle: parentName + memory + cpu + " ", // trailing space to ensure same height of all items
				icon: icon,
				arg: pid,
				uid: pid, // during rerun remembers selection, but does not affect sorting
				mods: {
					ctrl: { variables: { mode: "killall" } },
					cmd: { variables: { mode: "force kill" } },
					alt: {
						subtitle: `⌥: Copy PID   ${pid}`,
						variables: { mode: "copy pid" },
					},
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
		skipknowledge: true, // during rerun remembers selection, but does not affect sorting
		rerun: rerunSecs,
		items: processes,
	});
}
