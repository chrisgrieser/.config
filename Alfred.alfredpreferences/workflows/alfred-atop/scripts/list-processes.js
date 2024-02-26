#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// common apps where process name and app name are different
const processAppName = {
	// biome-ignore lint/style/useNamingConvention: usedAsDict
	Alfred: "Alfred 5",
	// biome-ignore lint/style/useNamingConvention: usedAsDict
	CleanShot: "CleanShot X",
	neovide: "Neovide",
	espanso: "Espanso",
	alacritty: "Alacritty",
	"wezterm-gui": "WezTerm",
	bird: "iCloud Sync",
	"Steam Helper": "Steam",
	// biome-ignore lint/style/useNamingConvention: usedAsDict
	steam_osx: "Steam",
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
	// biome-ignore lint/style/useNamingConvention: usedAsDict
	Finder: "/System/Library/CoreServices/Finder.app",
	"Alfred Preferences": "/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app",
};

const separator = "    ";
//──────────────────────────────────────────────────────────────────────────────

let rerunSecs = Number.parseFloat($.getenv("rerun_s_processes")) || 2.5;
if (rerunSecs < 0.1) rerunSecs = 0.1;
else if (rerunSecs > 5) rerunSecs = 5;

const cpuThresholdPercent = Number.parseFloat($.getenv("cpu_threshold_percent")) || 0.5;
const memoryThresholdMb = Number.parseFloat($.getenv("memory_threshold_mb")) || 10;
const sort = $.getenv("sort_key") === "Memory" ? "m" : "r";

const installedApps = app
	.doShellScript("ls /Applications/")
	.split("\r")
	.filter((line) => line.endsWith(".app"));

/** @param {string} str */
function camelCaseMatch(str) {
	const clean = str.replace(/[-_.]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// PERF store parent process names in dict, to reduce process name searches
	const parentProcs = {};

	const processes = app
		// command should come last, so it is not truncated and also fully
		// identifiable by space delimitation even with spaces in the process name
		// (command name can contain spaces, therefore last)
		.doShellScript(`ps ${sort}cAo 'pid=,ppid=,%cpu=,rss=,ruser=,command='`)
		.split("\r")
		.map((processInfo) => {
			// PID & name
			const [pid, ppid, cpuStr, memoryStr, isRoot, ...rest] = processInfo.trim().split(/ +/);
			const processName = rest.join(" ");
			if (processName === "<defunct>") return {};

			// parent process
			const parentInfo = parentProcs[ppid];
			let parentName;
			if (!parentInfo) {
				parentName = app.doShellScript(`ps -p ${ppid} -co 'command=' || true`);
				parentProcs[ppid] = { name: parentName, childrenCount: 1 };
			} else {
				parentName = parentInfo.name;
				parentProcs[ppid].childrenCount++;
			}
			// don't display parent if the name is obvious
			const parentIsObvious = processName.startsWith(parentName) || parentName === "launchd";
			if (parentIsObvious) parentName = "";

			// Memory, CPU & root
			let memory = (Number.parseInt(memoryStr) / 1024).toFixed(0).toString(); // real memory
			memory = Number.parseInt(memory) > memoryThresholdMb ? memory + "Mb" : "";
			const cpu = Number.parseFloat(cpuStr) > cpuThresholdPercent ? cpuStr + "%" : "";
			const isRootUser = isRoot === "root" ? " ⭕" : "";

			// display & icon
			if (parentName) parentName = "↖ " + parentName;
			const appName = processAppName[processName] || processName;
			const displayTitle =
				appName !== processName && !processName.includes("Helper")
					? `${processName} [${appName}]`
					: processName;
			const subtitle = [memory, cpu, parentName].filter((t) => t !== "").join(separator);
			const isApp = installedApps.includes(`${appName}.app`) || appFilePaths[appName];
			let icon = {};
			if (isApp) {
				const path = appFilePaths[appName] || `/Applications/${appName}.app`;
				icon = { type: "fileicon", path: path };
			}

			return {
				title: displayTitle + isRootUser,
				subtitle: subtitle,
				icon: icon,
				arg: pid,
				uid: pid, // during rerun remembers selection, but does not affect sorting
				match: camelCaseMatch(processName + parentName + appName),
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
		})
		// 2nd iteration now knowing which processes are parents
		.map((item) => {
			const isParent = Object.keys(parentProcs).includes(item.uid);
			if (isParent) {
				const children = parentProcs[item.uid].childrenCount;
				item.subtitle = `${children}⇣` + separator + item.subtitle;
				item.match += " parent";
			}
			return item;
		});

	return JSON.stringify({
		variables: { mode: "kill" },
		skipknowledge: true, // during rerun remembers selection, but does not affect sorting
		rerun: rerunSecs,
		items: processes,
	});
}
