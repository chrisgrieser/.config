#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let deviceArr = [];

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

	// `ioreg` only includes Apple keyboards, mice, and trackpads, but does have
	// battery data for them
	const applePeriphery = {};
	JSON.parse(
		// data as xml -> remove "data" key -> convert to json
		app.doShellScript("ioreg -rak BatteryPercent | sed 's/data>/string>/' | plutil -convert json - -o -"),
	).forEach((/** @type {{ DeviceAddress: string; }} */ device) => {
		// make address consistent with output from `system_profiler` consistent
		const address = device.DeviceAddress.toUpperCase().replaceAll("-", ":");
		applePeriphery[address] = device;
	});

	//───────────────────────────────────────────────────────────────────────────

	console.log("deviceArr:", JSON.stringify(deviceArr));
	deviceArr = deviceArr.map((device) => {
		const batteryLevel =
			applePeriphery[device.device_address]?.BatteryPercent || parseInt(device.device_batteryLevelMain) || -1;
		const battery = batteryLevel > -1 ? `🔋 ${batteryLevel}%` : "";
		const connected = device.connected ? "🔌 " : "";

		return {
			title: device.device_name,
			subtitle: connected + battery,
		};
	});

	return JSON.stringify({ items: deviceArr });
}
