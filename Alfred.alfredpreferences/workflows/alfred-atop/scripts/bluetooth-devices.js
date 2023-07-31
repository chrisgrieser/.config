#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

let rerunSecs = parseFloat($.getenv("rerun_s_bluetooth")) || 2.5;
if (rerunSecs < 0.1) rerunSecs = 0.1;
else if (rerunSecs > 5) rerunSecs = 5;

const excludedDevices = ($.getenv("excluded_devices") || "").split(",").map((t) => t.trim());

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	let deviceArr = [];
	const allDevices = JSON.parse(app.doShellScript("system_profiler -json SPBluetoothDataType"))
		.SPBluetoothDataType[0];
	if (allDevices.device_connected) {
		allDevices.device_connected.forEach((/** @type {{ [x: string]: any; }} */ device) => {
			const name = Object.keys(device)[0];
			const properties = device[name];
			properties.device_name = name;
			properties.connected = true;
			deviceArr.push(properties);
		});
	}
	if (allDevices.device_not_connected) {
		allDevices.device_not_connected.forEach((/** @type {{ [x: string]: any; }} */ device) => {
			const name = Object.keys(device)[0];
			const properties = device[name];
			properties.device_name = name;
			properties.connected = false;
			deviceArr.push(properties);
		});
	}

	// INFO some macOS versions use a different property for that (see issue #2)
	if (allDevices.device_title) {
		allDevices.device_title.forEach((/** @type {{ [x: string]: any; }} */ device) => {
			const name = Object.keys(device)[0];
			const properties = device[name];
			// make keys consistent with the other versions of the output
			properties.device_minorType = properties.device_minorClassOfDevice_string;
			properties.device_name = name;
			properties.connected = properties.device_isconnected === "attrib_Yes";
			// WARN do not use `replaceAll` because it doesn't work on older macOS versions
			properties.device_address = properties.device_addr.replace(/_/g, ":");
			deviceArr.push(properties);
		});
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
	JSON.parse(applePeriData).forEach((/** @type {{ DeviceAddress: string; }} */ device) => {
		// make address consistent with output from `system_profiler`
		// WARN do not use `replaceAll` because it doesn't work on older macOS versions
		const address = device.DeviceAddress.toUpperCase().replace(/-/g, ":");
		applePeriphery[address] = device;
	});

	//───────────────────────────────────────────────────────────────────────────

	deviceArr = deviceArr.map((device) => {
		const batteryLevel =
			applePeriphery[device.device_address]?.BatteryPercent || parseInt(device.device_batteryLevelMain) || -1;
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
			Keyboard: "⌨️",
			Mouse: "🖱️",
			AppleTrackpad: "🖲️",
			Gamepad: "🎮",
			Headphones: "🎧",
			Headset: "🎧",
		};
		if (type) category = typeIcons[type];
		else if (name.toLowerCase().includes("phone")) category = "📱";

		return {
			title: `${name} ${category}`,
			subtitle: connected + battery + distance,
			arg: device.device_address,
		};
	});

	return JSON.stringify({ items: deviceArr });
}
