#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} path */
function readFile(path) {
	const data = $.NSFileManager.defaultManager.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

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
	const rerunSecs = Number.parseFloat($.getenv("rerun_s_processes"));
	const cpuThresholdPercent = Number.parseFloat($.getenv("cpu_threshold_percent")) || 0.5;
	const memoryThresholdMb = Number.parseFloat($.getenv("memory_threshold_mb")) || 10;
	const sort = $.getenv("sort_key") === "Memory" ? "m" : "r";

	/** @type {Record<string, { name: string; childrenCount: number }> } */
	const parentProcs = {};

	// common apps where process name and app name are different
	/** @type {Record<string, Record<string, string>>} */
	const { processAppName, appFilePaths } = JSON.parse(readFile("./scripts/app-process-info.json"));

	const installedApps = app
		.doShellScript("ls /Applications/")
		.split("\r")
		.filter((line) => line.endsWith(".app"));

	// INFO command should come last, so it is not truncated and also fully
	// identifiable by space delimitation even with spaces in the process name
	// (command name can contain spaces, therefore last)
	const shellCmd = `ps ${sort}cAo 'pid=,ppid=,%cpu=,rss=,ruser=,command='`;

	/** @type {AlfredItem[]} */
	const processes = app
		.doShellScript(shellCmd)
		.split("\r")
		.reduce((/** @type {AlfredItem[]} */ acc, processInfo) => {
			// PID & name
			const [pid, ppid, cpuStr, memoryStr, isRoot, ...rest] = processInfo.trim().split(/ +/);
			const processName = rest.join(" ");
			if (processName === "<defunct>") return acc;

			// parent process
			const parentInfo = parentProcs[ppid];
			let parentName;
			if (parentInfo) {
				parentName = parentInfo.name;
				parentProcs[ppid].childrenCount++;
			} else {
				parentName = app.doShellScript(`ps -p ${ppid} -co 'command=' || true`);
				parentProcs[ppid] = { name: parentName, childrenCount: 1 };
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
			const subtitle = [memory, cpu, parentName].filter((t) => t !== "").join("    ");
			const isApp = installedApps.includes(`${appName}.app`) || appFilePaths[appName];
			let icon = {};
			if (isApp) {
				const path = appFilePaths[appName] || `/Applications/${appName}.app`;
				icon = { type: "fileicon", path: path };
			}

			/** @type {AlfredItem} */
			const alfredItem = {
				title: displayTitle + isRootUser,
				subtitle: subtitle,
				icon: icon,
				arg: pid,
				uid: pid, // during rerun remembers selection, but does not affect sorting
				match: camelCaseMatch(processName + parentName + appName),
				mods: {
					ctrl: { variables: { mode: "killall" } },
					cmd: { variables: { mode: "force kill" } },
					"cmd+ctrl": { variables: { mode: "force killall" } },
					alt: {
						subtitle: `⌥: Copy PID   ${pid}`,
						variables: { mode: "copy pid" },
					},
					shift: {
						valid: Boolean(isApp),
						subtitle: isApp ? "⇧: Restart App" : "⇧: ⛔ Not an app",
						variables: { mode: "restart app" },
					},
				},
			};
			acc.push(alfredItem);
			return acc;
		}, [])
		// 2nd iteration now knowing which processes are parents
		.map((item) => {
			if (!item.uid) return item;
			const isParent = Object.keys(parentProcs).includes(item.uid);
			if (isParent) {
				const children = parentProcs[item.uid].childrenCount;
				item.subtitle = `${children}⇣    ${item.subtitle}`;
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
