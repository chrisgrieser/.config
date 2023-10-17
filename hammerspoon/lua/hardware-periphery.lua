local M = {} -- persist from garbage collector

local u = require("lua.utils")
--------------------------------------------------------------------------------
-- USB WATCHER

-- backup device: open terminal
-- otherwise: open in Finder
M.usb_externalDrive = hs.usb.watcher
	.new(function(device)
		local name = device.productName
		local ignore = {
			"Integrated RGB Camera", -- Docking Station in the office
			"CHERRY Wireless Device" -- Mouse at mother
		} 
		if u.tbl_contains(ignore, name) or device.eventType ~= "added" then return end

		u.notify("Mounted: " .. name)

		local harddriveNames = {
			"ZY603 USB3.0 Device", -- Externe A
			"External Disk 3.0", -- Externe B
			"Elements 2621", -- Externe C
		}

		if u.tbl_contains(harddriveNames, name) then
			hs.application.open("WezTerm")
		else
			-- search for mounted volumes, since the usb-watcher does not report it to us
			u.runWithDelays({ 1, 2, 4 }, function()
				local stdout, success =
					hs.execute([[df -h | grep -io "\s/Volumes/.*" | cut -c2- | head -n1]])
				if not success or not stdout then return end
				local path = stdout:gsub("\n$", "")
				hs.open(path)
			end)
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- BLUETOOTH/BATTERY

M.timer_dailyBatteryCheck = hs.timer
	.doAt("14:30", "01d", function()
		local warningLevel = 15
		local devices = hs.battery.privateBluetoothBatteryInfo()
		if not devices then return end

		for _, device in pairs(devices) do
			local percent = tonumber(device.batteryPercentSingle)
			if percent > warningLevel then return end
			local msg = ("%s Battery is low (%s)"):format(device.name, percent)
			u.notify("⚠️", msg)
		end
	end, true)
	:start()

--------------------------------------------------------------------------------
return M
