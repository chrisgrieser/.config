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

/** @returns {string[]} names of the `.app` bundles in /Applications */
function listInstalledApps() {
	// PERF using the file manager instead of `ls` saves spawning a shell + process
	try {
		const entries = ObjC.deepUnwrap(
			$.NSFileManager.defaultManager.contentsOfDirectoryAtPathError("/Applications", $()),
		);
		if (Array.isArray(entries)) return entries.filter((name) => name.endsWith(".app"));
	} catch (_error) {
		// fall through to shell fallback
	}
	return app
		.doShellScript("ls /Applications/")
		.split("\r")
		.filter((line) => line.endsWith(".app"));
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const invertSort =
		$.NSProcessInfo.processInfo.environment.objectForKey("invertSorting").js === "true";
	const sortBy = $.getenv("sort_key");
	const rerunSecs = Number.parseFloat($.getenv("rerun_s_processes"));
	const cpuThresholdPercent = Number.parseFloat($.getenv("cpu_threshold_percent")) || 0.5;
	const memoryThresholdMb = Number.parseFloat($.getenv("memory_threshold_mb")) || 10;
	const showPid = $.getenv("show_pid") === "1";

	/** @type {Record<string, { name: string; childrenCount: number }> } */
	const parentProcs = {}; // PERF `Map` not quicker, probably due to low integer keys

	// common apps where process name and app name are different
	/** @type {Record<string, Record<string, string>>} */
	const { processAppName, appFilePaths } = JSON.parse(readFile("./scripts/app-process-info.json"));

	const installedApps = listInstalledApps();

	const sortByMemory = (sortBy === "Memory" && !invertSort) || (sortBy === "CPU" && invertSort);
	const sortArg = sortByMemory ? "m" : "r";
	// INFO `command=` should come last, so it is not truncated and also fully
	// identifiable by space delimitation even with spaces in the process name
	const shellCmd = `ps -${sortArg}cAo 'pid=,ppid=,%cpu=,rss=,ruser=,command='`;

	// PERF the `ps` output already contains every parent, so build a pid -> name
	// lookup from it instead of spawning one `ps -p` shell per distinct parent
	const psLines = app.doShellScript(shellCmd).split("\r");
	/** @type {Record<string, string>} */
	const nameByPid = {};
	for (const line of psLines) {
		const [pid, , , , , ...rest] = line.trim().split(/ +/);
		nameByPid[pid] = rest.join(" ");
	}

	/** @type {AlfredItem[]} */
	const processes = psLines
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
				parentName = nameByPid[ppid] || "";
				parentProcs[ppid] = { name: parentName, childrenCount: 1 };
			}
			// don't display parent if the name is obvious
			const parentIsObvious = processName.startsWith(parentName) || parentName === "launchd";
			if (parentIsObvious) parentName = "";

			// Memory, CPU & root
			let memory = (Number.parseInt(memoryStr) / 1024).toFixed(0).toString(); // real memory
			memory = Number.parseInt(memory) > memoryThresholdMb ? memory + " MB" : "";
			const cpu = Number.parseFloat(cpuStr) > cpuThresholdPercent ? cpuStr + "%" : "";
			const isRootUser = isRoot === "root" ? " ⭕" : "";

			// display & icon
			if (parentName) parentName = "↖ " + parentName;
			const appName = processAppName[processName] || processName;
			const displayTitle =
				appName !== processName && !processName.includes("Helper")
					? `${processName} [${appName}]`
					: processName;

			const subtitle = [parentName, memory, cpu, showPid ? `[${pid}]` : ""]
				.filter(Boolean)
				.join("    ");

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
				text: { copy: pid },
				variables: { mode: "kill" }, // when just using `enter`
				mods: {
					ctrl: { variables: { mode: "killall" } },
					cmd: { variables: { mode: "force kill" } },
					"cmd+ctrl": { variables: { mode: "force killall" } },
					alt: {
						subtitle: "⌥: Copy process path",
						variables: { mode: "copy process path" },
					},
					shift: {
						valid: Boolean(isApp),
						subtitle: isApp ? "⇧: Restart App" : "⇧: ⛔ Not an app",
						variables: { mode: "restart app" },
					},
					fn: {
						variables: { invertSorting: (!invertSort).toString() },
						subtitle: "fn: Sort processes by " + (sortByMemory ? "CPU" : "Memory"),
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
		skipknowledge: true, // during rerun remembers selection, but does not affect sorting
		rerun: rerunSecs,
		items: processes,
	});
}
