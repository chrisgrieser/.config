#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
ObjC.import("IOBluetooth");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// DOCS https://developer.apple.com/documentation/iobluetooth/iobluetoothdevice
	const selectedDeviceAddress = argv[0];
	/** @type {BluetoothDevice[]} */
	const devices = $.IOBluetoothDevice.pairedDevices.js;
	const device = devices.find((d) => d.addressString.js === selectedDeviceAddress);
	if (!device) return "⚠️ Unknown error.";

	// SIC function call without `()`, due to being Objective-C?
	device.isConnected ? device.closeConnection : device.openConnection;

	// notification
	const action = device.isConnected ? "🔴 Disconnected from" : "🟢 Connected to";
	const alfredNotifMsg = `${action} "${device.nameOrAddress.js}"`;
	return alfredNotifMsg;
}
