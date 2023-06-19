#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// const deviceArr = [];

	const appleDevices = app
		.doShellScript("ioreg -rk BatteryPercent")
		.split("\r\r")
	// 	.filter((line) => line.includes("BatteryPercent") || line.includes("Product"));
	// let appleDevice;
	// appleDevices.forEach((line) => {
	// 	const value = line.split(" = ")[1].replaceAll('"', "");
	// 	if (line.includes("Product")) appleDevice.name = value;
	// 	if (line.includes("BatteryPercent")) {
	// 		appleDevice.battery = value;
	// 		deviceArr.push(appleDevice);
	// 		appleDevice = {};
	// 	}
	// });

	// const allDevices = app
	// 	.doShellScript("system_profiler -json SPBluetoothDataType")
	// 	.split("\r")
	// 	.filter((line) => line.includes("BatteryPercent") || line.includes("Product"));

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
