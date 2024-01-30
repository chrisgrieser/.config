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

local output, success = hs.execute(
	"ioreg -rak BatteryPercent | sed 's/data>/string>/' | plutil -convert json - -o -"
)
if not success then return end
local devices = hs.json.decode(output) or {}
for _, device in pairs(devices) do
	local percent = device.BatteryPercent
	local name = device.Product
	local msg = ("🔋 %s Battery low (%s)"):format(name, percent)
end

M.timer_dailyBatteryCheck = hs.timer
	.doAt("14:30", "01d", function()
		local warnBelowPercent = 20 -- CONFIG

		-- get battery info
		-- `privateBluetoothBatteryInfo()` is not reliable, therefore retrieving
		-- battery status directly from the system
		local output, success = hs.execute(
			"ioreg -rak BatteryPercent | sed 's/data>/string>/' | plutil -convert json - -o -"
		)
		if not success then return end
		local devices = hs.json.decode(output) or {}

		for _, device in pairs(devices) do
			local percent = device.BatteryPercent
			local name = device.Product
			local msg = ("🔋 %s Battery low (%s)"):format(name, percent)
			-- battery info incorrect for non-Apple devices
			if percent < warnBelowPercent then
				local msg = ("🔋 %s Battery low (%s)"):format(name, percent)

				-- notification & Reminder
				u.notify("⚠️", msg)
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
