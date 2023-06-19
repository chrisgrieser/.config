#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let deviceArr = [];

	const appleDevices = JSON.parse( app.doShellScript("ioreg -rak BatteryPercent | sed 's/data/string/' | plutil -convert json - -o -"))
		.map((device) => {
			const serial = device.serialNumber;
			return {};
		});
	const allDevices = JSON.parse(app.doShellScript("system_profiler -json SPBluetoothDataType")).SPBluetoothDataType[0];

	allDevices.device_connected.forEach((/** @type {{ [x: string]: any; }} */ device) => {
		const name = Object.keys(device)[0];
		const properties = device[name];
		properties.device_name = name;
		properties.connected = true;
		deviceArr.push(properties);
	});
	allDevices.device_not_connected.forEach((/** @type {{ [x: string]: any; }} */ device) => {
		const name = Object.keys(device)[0];
		const properties = device[name];
		properties.device_name = name;
		properties.connected = false;
		deviceArr.push(properties);
	});

	deviceArr = deviceArr.map((device) => {
		console.log("device_name:", device.device_name);

		return {
			title: device.device_name,
			subtitle: device.connected ? "connected" : "not connected",
		};
	});

	return JSON.stringify({ items: deviceArr });
}
