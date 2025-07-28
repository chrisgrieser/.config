#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
ObjC.import("IOBluetooth");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// https://developer.apple.com/documentation/iobluetooth/iobluetoothdevice
const devicesRaw = ObjC.unwrap($.IOBluetoothDevice.pairedDevices);
const allDevices = Array.from(devicesRaw, (device) => {
	return {
		name: ObjC.unwrap(device.nameOrAddress),
		connected: ObjC.unwrap(device.isConnected),
		address: ObjC.unwrap(device.addressString),
	};
});
