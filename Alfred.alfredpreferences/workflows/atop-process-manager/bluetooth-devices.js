#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// const deviceArr = [];

	const appleDevices = JSON.parse(app.doShellScript("ioreg -rak BatteryPercent | sed 's/data/string/' | plutil -convert json - -o -"))

	const allDevices = JSON.parse(app.doShellScript("system_profiler -json SPBluetoothDataType"))

	// /** @type AlfredItem[] */
	// const devicesArr = app.doShellScript("")
	// 	.split("\r")
	// 	.map(item => {
	//
	// 		return {
	// 			title: item,
	// 			subtitle: item,
	// 			arg: item,
	// 			uid: item,
	// 		};
	// 	});
	JSON.stringify({ items: appleDevices });
}
