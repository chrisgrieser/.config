#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
ObjC.import("IOBluetooth");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	const selectedDeviceAddress = argv[0];

  const device = $.IOBluetoothDevice.pairedDevices.js
    .find(device => device.addressString.js === argv[0])
  const connected = device.isConnected
  const maxTimeout = Date.now() + 5000

  // Toggle connection
  connected ? device.closeConnection : device.openConnection

  // Wait (with timeout) for connection to toggle before allowing script to terminate
  while (device.isConnected === connected && Date.now() < maxTimeout) delay(0.5)

	// DOCS https://developer.apple.com/documentation/iobluetooth/iobluetoothdevice
	const devicesRaw = ObjC.unwrap($.IOBluetoothDevice.pairedDevices);
	const allDevices = Array.from(devicesRaw, (d) => {
		return {
			name: ObjC.unwrap(d.nameOrAddress),
			connected: ObjC.unwrap(d.isConnected),
			address: ObjC.unwrap(d.addressString),
			instance: d,
		};
	});

	const device = allDevices.find((d) => d.address === selectedDeviceAddress);
	if (!device) return "⚠️ Unknown error.";

	// SIC function call without `()`, due to being Objective-C
	if (device.connected) device.instance.closeConnection;
	else device.instance.openConnection;

	const action = device.connected ? "🔴 Disconnected from" : "🟢 Connected to";
	const alfredNotifMsg = `${action} "${device.name}"`;
	return alfredNotifMsg;
}
