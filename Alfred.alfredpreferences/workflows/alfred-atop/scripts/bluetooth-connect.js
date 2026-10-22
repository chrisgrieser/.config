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

	// GUARD: connecting/disconnecting drives the Bluetooth radio, which requires
	// the "Bluetooth" privacy permission. macOS updates routinely reset this. When
	// it is missing, `openConnection` silently no-ops and even returns success (0),
	// so we must check authorization explicitly rather than trust the return code.
	// @ts-expect-error CBManager constants resolve globally in JXA
	if ($.CBManager.authorization !== $.CBManagerAuthorizationAllowedAlways) {
		return "⛔ Bluetooth permission missing. Grant Alfred access in System Settings → Privacy & Security → Bluetooth.";
	}

	const selectedDeviceAddress = argv[0];
	/** @type {BluetoothDevice[]} */
	const devices = $.IOBluetoothDevice.pairedDevices.js;
	const device = devices.find((d) => d.addressString.js === selectedDeviceAddress);
	if (!device) return "⚠️ Unknown error.";

	const name = device.nameOrAddress.js;
	const wasConnected = device.isConnected;

	if (wasConnected) {
		// SIC function call without `()`, due to being Objective-C. Returns an IOReturn.
		device.closeConnection;
	} else {
		// SIC function call works when null is passed as argument.
		device.openConnection(null);
	}

	// VERIFY the state actually flipped. openConnection/closeConnection can report
	// success while doing nothing (device off/unreachable, or missing permission),
	// and the radio update is not instantaneous, so poll briefly for the change.
	let isConnected = device.isConnected;
	for (let i = 0; i < 12 && isConnected === wasConnected; i++) {
		delay(0.5);
		isConnected = device.isConnected;
	}

	if (isConnected === wasConnected) {
		const failedAction = wasConnected ? "disconnect from" : "connect to";
		return `⚠️ Failed to ${failedAction} "${name}". Is it powered on and in range?`;
	}

	// notification
	const action = wasConnected ? "🔴 Disconnected from" : "🟢 Connected to";
	return `${action} "${name}"`;
}
