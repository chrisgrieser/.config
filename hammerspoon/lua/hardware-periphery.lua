local u = require("lua.utils")
--------------------------------------------------------------------------------

-- USB WATCHER

-- if backup device: open terminal
ExternalHarddriveWatcher = hs.usb.watcher
	.new(function(device)
		if not (device.eventType == "added") then return end
		local name = device.productName

		local harddriveNames = {
			"ZY603 USB3.0 Device", -- Externe A
			"External Disk 3.0", -- Externe B
			"Elements 2621", -- Externe C
		}

		if u.tbl_contains(harddriveNames, name) then hs.application.open("WezTerm") end
	end)
	:start()

--------------------------------------------------------------------------------
-- BLUETOOTH/BATTERY

---notifies & writes reminder
---is low. Caveat: `hs.battery` seems to work only with Apple devices.
local function batteryCheck()
	local warningLevel = 15
	local devices = hs.battery.privateBluetoothBatteryInfo()
	if not devices then return end

	for _, device in pairs(devices) do
		local percent = tonumber(device.batteryPercentSingle)
		if percent > warningLevel then return end
		local msg = ("%s Battery is low (%s)"):format(device.name, percent)
		u.notify("⚠️", msg)
	end
end

DailyBatteryCheckTimer = hs.timer.doAt("14:30", "01d", batteryCheck, true):start()
