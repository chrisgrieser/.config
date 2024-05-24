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
			"CHERRY Wireless Device", -- Mouse at mother
			"SP 150", -- RICOH printer
			"Integrated RGB Camera", -- Docking Station in the office
			"USB 10/100/1000 LAN", -- ^
			"T27hv-20", -- ^
		}
		if hs.fnutils.contains(ignore, name) or device.eventType ~= "added" then return end

		u.notify("Mounted: " .. name)

		local harddriveNames = {
			"ZY603 USB3.0 Device", -- Externe A
			"External Disk 3.0", -- Externe B
			"Elements 2621", -- Externe C
		}

		if hs.fnutils.contains(harddriveNames, name) then
			hs.application.open("WezTerm")
		else
			-- search for mounted volumes, since the usb-watcher does not report it to us
			u.runWithDelays(
				{ 1, 3 },
				function()
					hs.execute([[
						df | grep --max-count=1 " /Volumes/" | awk -F '   ' '{print $NF}' | 
							xargs -I {} open {}
					]])
				end
			)
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- BLUETOOTH/BATTERY

---@param msg string
local function createReminder(msg)
	hs.osascript.javascript(([[
		const rem = Application("Reminders");
		const today = new Date();
		const newReminder = rem.Reminder({ name: "%s", alldayDueDate: today });
		rem.defaultList().reminders.push(newReminder);
		rem.quit();
	]]):format(msg))
end

M.timer_dailyBatteryCheck = hs.timer
	.doAt("14:30", "01d", function()
		local warnBelowPercent = 20 -- CONFIG

		-- INFO `privateBluetoothBatteryInfo()` is not reliable, therefore retrieving
		-- battery status directly from the system.
		-- CAVEAT `ioreg` only works for Apple devices
		local output, success = hs.execute(
			"ioreg -rak BatteryPercent | sed 's/data>/string>/' | plutil -convert json - -o -"
		)
		if not success then return end
		local devices = hs.json.decode(output) or {}

		for _, device in pairs(devices) do
			local percent = device.BatteryPercent
			local name = device.Product

			-- battery info incorrect for non-Apple devices
			if percent < warnBelowPercent then
				local msg = ("🔋 %s Battery low (%s)"):format(name, percent)
				u.notify(msg)
				createReminder(msg)
			end
		end
	end, true)
	:start()

--------------------------------------------------------------------------------
return M
