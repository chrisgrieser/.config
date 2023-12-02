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
			"USB 10/100/1000 LAN", -- Docking Station in the office
			"CHERRY Wireless Device", -- Mouse at mother
			"SP 150", -- RICOH printer
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
			u.runWithDelays({ 1, 3 }, function()
				local stdout, success =
					hs.execute([[df | grep --only-matching --max-count=1 " /Volumes/.*" | cut -c2-]])
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
		local warnBelowPercent = 20

		-- `privateBluetoothBatteryInfo()` apparently retrieves battery info only
		-- once on the first load and not dynamically on every call. Thus, so we
		-- need to unload and reload the module to force a refresh of the
		-- percentage values
		package.loaded["hs.battery"] = nil

		local devices = hs.battery.privateBluetoothBatteryInfo()
		if not devices then return end

		for _, device in pairs(devices) do
			local percent = tonumber(device.batteryPercentSingle)
			-- battery info incorrect for non-Apple devices
			if percent < warnBelowPercent and device.isApple == "YES" then
				local msg = ("🔋 %s Battery low (%s)"):format(device.name, percent)
				u.notify("⚠️", msg)

				-- new Reminder
				hs.osascript.javascript(([[
					const rem = Application("Reminders");
					const today = new Date();
					const newReminder = rem.Reminder({ name: "%s", alldayDueDate: today });
					rem.defaultList().reminders.push(newReminder);
					rem.quit();
				]]):format(msg))
			end
		end
	end, true)
	:start()

--------------------------------------------------------------------------------
return M
