#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
ObjC.import("IOBluetooth");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// TODO assess whether `ObjC.import("IOBluetooth")` is useful
// https://github.com/bosha/alfred-blueman-workflow/blob/master/src/bt_manager.jxa

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const rerunSecs = Number.parseFloat($.getenv("rerun_s_bluetooth"));
	const excludedDevices = $.getenv("excluded_devices").split(/ *, */);

	// DOCS https://developer.apple.com/documentation/iobluetooth/iobluetoothdevice
	const devicesRaw = ObjC.unwrap($.IOBluetoothDevice.pairedDevices);
	const allDevices = Array.from(devicesRaw, (device) => {
		return {
			name: ObjC.unwrap(device.nameOrAddress),
			connected: ObjC.unwrap(device.isConnected),
			address: ObjC.unwrap(device.addressString),
		};
	});

	//───────────────────────────────────────────────────────────────────────────

	// INFO `ioreg` only includes Apple periphery, but has battery info for them.
	let applePeriData = app.doShellScript(
		"ioreg -rak BatteryPercent | sed 's/data>/string>/' | plutil -convert json - -o - || true",
	);
	// prevent JSON.parse from failing when there is no periphery data
	if (applePeriData.startsWith("<stdin>: Property List error")) applePeriData = "[]";

	const /** @type {Record<string, any>} */ applePeriphery = {};
	for (const device of JSON.parse(applePeriData)) {
		applePeriphery[device.DeviceAddress] = device;
	}

	//───────────────────────────────────────────────────────────────────────────

	const deviceArr = allDevices.map((device) => {
		if (excludedDevices.includes(device.name)) return {};

		const batteryLevel = applePeriphery[device.address]?.BatteryPercent || -1;
		const batteryLow = batteryLevel < 10 ? "⚠️" : "";
		const battery = batteryLevel > -1 ? `${batteryLow}${batteryLevel}%` : "";
		const connected = device.connected ? "🟢 " : "🔴 ";

		return {
			title: device.name,
			subtitle: `${connected} ${battery}`,
			arg: device.address,
		};
	});

	return JSON.stringify({
		rerun: rerunSecs,
		items: deviceArr,
	});
}
