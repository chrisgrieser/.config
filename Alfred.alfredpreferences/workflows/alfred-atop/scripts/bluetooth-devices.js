#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
ObjC.import("IOBluetooth");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// DOCS https://developer.apple.com/documentation/iobluetooth/iobluetoothdevice
/** @typedef {Object} BluetoothDevice
 * @property {{js: string}} nameOrAddress
 * @property {boolean} isConnected
 * @property {{js: string}} addressString
 * @property {unknown} closeConnection
 * @property {unknown} openConnection
 */

//────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// GUARD
	const osVersion = $.NSProcessInfo.processInfo.operatingSystemVersion;
	if (parseInt(osVersion.majorVersion) < 10 && parseInt(osVersion.minorVersion) < 15) {
		return JSON.stringify({
			items: [{ title: "⛔ This feature requires at least macOS 10.15", valid: false }],
		});
	}
	// @ts-expect-error
	if ($.CBManager.authorization !== $.CBManagerAuthorizationAllowedAlways) {
		const item = {
			title: "⛔ Unable to access Bluetooth",
			subtitle: "Open System Settings, then grant Alfred Bluetooth permissions.",
			valid: false,
		};
		return JSON.stringify({ items: [item] });
	}
	//───────────────────────────────────────────────────────────────────────────

	const excludedDevices = $.getenv("excluded_devices").split(/ *, */);

	/** @type {BluetoothDevice[]} */
	const devices = $.IOBluetoothDevice.pairedDevices.js;

	/** @type {AlfredItem[]} */
	const deviceArr = devices.flatMap((device) => {
		const name = device.nameOrAddress.js;
		const connectedIcon = device.isConnected ? "🟢 " : "🔴 ";
		const address = device.addressString.js;
		if (excludedDevices.includes(name)) return [];

		return {
			title: name,
			subtitle: connectedIcon,
			uid: address,
			arg: address,
		};
	});

	return JSON.stringify({ rerun: 1, items: deviceArr });
}
