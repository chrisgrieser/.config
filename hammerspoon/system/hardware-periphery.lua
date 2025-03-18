local M = {} -- persist from garbage collector

local u = require("meta.utils")
--------------------------------------------------------------------------------
-- USB WATCHER

-- backup device: open terminal
-- otherwise: open in Finder
M.usb_externalDrive = hs.usb.watcher
	.new(function(device)
		local name = device.productName
		u.notify("Mounted: " .. name)

		local ignore = {
			"CHERRY Wireless Device", -- Mouse at mother
			"Keychron K3", ------------- Keyboard at home & office
			"SP 150", ------------------ RICOH printer
			"Integrated RGB Camera", --- Docking Station in the office
			"USB 10/100/1000 LAN", ----- ^
			"T27hv-20", ---------------- ^
		}
		if hs.fnutils.contains(ignore, name) or device.eventType ~= "added" then return end

		local harddriveNames = {
			"ZY603 USB3.0 Device", -- Externe A
			"External Disk 3.0", ---- Externe B
			"Elements 2621", -------- Externe C
		}

		if hs.fnutils.contains(harddriveNames, name) then
			hs.application.open("WezTerm")
		else
			-- search for mounted volumes, since the usb-watcher does not report it to us
			local cmd =
				'df | grep " /Volumes/" | grep -v "/Volumes/Recovery" | awk -F "   " "{print $NF}" | head -n1 | xargs open'
			u.defer({ 1, 3 }, function() hs.execute(cmd) end)
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- BATTERY

M.timer_dailyBatteryCheck = hs.timer
	.doAt("14:30", "01d", function()
		local warnBelowPercent = 10 -- CONFIG

		-- INFO `privateBluetoothBatteryInfo()` is not reliable, therefore retrieving
		-- battery status directly from the system.
		-- CAVEAT `ioreg` only works for Apple devices
		local cmd = "ioreg -rak BatteryPercent | sed 's/data>/string>/' | plutil -convert json - -o -"
		local output, success = hs.execute(cmd)
		if not success then return end
		local devices = hs.json.decode(output) or {}

		for _, d in pairs(devices) do
			if d.BatteryPercent < warnBelowPercent then
				local msg = ("🔋 %s Battery low (%s)"):format(d.Product, d.BatteryPercent)
				u.notify(msg)

				-- create reminder
				hs.osascript.javascript(([[
					const rem = Application("Reminders");
					const today = new Date();
					const newReminder = rem.Reminder({ name: %q, alldayDueDate: today });
					rem.defaultList().reminders.push(newReminder);
					rem.quit();
				]]):format(msg))
				hs.execute(u.exportPath .. "sketchybar --trigger update_reminder_count")
			end
		end
	end, true)
	:start()

--------------------------------------------------------------------------------
return M
