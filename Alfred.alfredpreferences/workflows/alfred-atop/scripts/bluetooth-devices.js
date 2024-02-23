#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

let rerunSecs = Number.parseFloat($.getenv("rerun_s_bluetooth")) || 2.5;
if (rerunSecs < 0.1) rerunSecs = 0.1;
else if (rerunSecs > 5) rerunSecs = 5;

const excludedDevices = ($.getenv("excluded_devices") || "").split(",").map((t) => t.trim());

//──────────────────────────────────────────────────────────────────────────────
// TODO assess whether `ObjC.import("IOBluetooth")` is useful
// https://github.com/bosha/alfred-blueman-workflow/blob/master/src/bt_manager.jxa

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let deviceArr = [];
	const allDevices = JSON.parse(app.doShellScript("system_profiler -json SPBluetoothDataType"))
		.SPBluetoothDataType[0];
	if (allDevices.device_connected) {
		for (const device of allDevices.device_connected) {
			const name = Object.keys(device)[0];
			const properties = device[name];
			properties.device_name = name;
			properties.connected = true;
			deviceArr.push(properties);
		}
	}
	if (allDevices.device_not_connected) {
		for (const device of allDevices.device_not_connected) {
			const name = Object.keys(device)[0];
			const properties = device[name];
			properties.device_name = name;
			properties.connected = false;
			deviceArr.push(properties);
		}
	}

	// INFO some macOS versions use a different property for that (see #2)
	if (allDevices.device_title) {
		for (const device of allDevices.device_title) {
			const name = Object.keys(device)[0];
			const properties = device[name];
			// ADAPTER make keys consistent with the other versions of the output
			properties.device_minorType = properties.device_minorClassOfDevice_string;
			properties.device_name = name;
			properties.connected = properties.device_isconnected === "attrib_Yes";
			// WARN do not use `replaceAll` because it doesn't work on older macOS versions
			properties.device_address = properties.device_addr.replace(/_/g, ":");
			deviceArr.push(properties);
		}
	}

	// INFO `ioreg` only includes Apple keyboards, mice, and trackpads, but does
	// have battery data for them which is missing from the `system_profiler` output.
	const applePeriphery = {};
	let applePeriData = app.doShellScript(
		"ioreg -rak BatteryPercent | sed 's/data>/string>/' | plutil -convert json - -o - || true",
	);
	// no apple periphery -> defaulting to "[]" so JSON.parse() doesn't fail
	if (applePeriData.startsWith("<stdin>: Property List error")) applePeriData = "[]";

	// data as xml -> remove "data" key -> convert to json
	for (const device of JSON.parse(applePeriData)) {
		// make address consistent with output from `system_profiler`
		// WARN do not use `replaceAll` because it doesn't work on older macOS versions
		const address = device.DeviceAddress.toUpperCase().replace(/-/g, ":");
		applePeriphery[address] = device;
	}

	//───────────────────────────────────────────────────────────────────────────

	deviceArr = deviceArr.map((device) => {
		const batteryLevel =
			applePeriphery[device.device_address]?.BatteryPercent ||
			Number.parseInt(device.device_batteryLevelMain) ||
			-1;
		const batteryLow = batteryLevel < 20 ? "⚠️" : "";
		const battery = batteryLevel > -1 ? `${batteryLow}${batteryLevel}%` : "";
		const connected = device.connected ? "🟢 " : "🔴 ";
		const distance = device.device_rssi ? ` rssi: ${device.device_rssi}` : "";
		const name = device.device_name;
		if (excludedDevices.includes(name)) return {};
		const type = device.device_minorType;

		// icon
		let category = "";
		const typeIcons = {
			keyboard: "⌨️",
			mouse: "🖱️",
			appletrackpad: "🖲️",
			gamepad: "🎮",
			headphones: "🎧",
			headset: "🎧",
		};
		if (type) category = typeIcons[type.toLowerCase()];
		else if (name.toLowerCase().includes("phone")) category = "📱";

		return {
			title: `${name} ${category}`,
			subtitle: connected + battery + distance,
			arg: device.device_address,
		};
	});

	return JSON.stringify({ items: deviceArr });
}
