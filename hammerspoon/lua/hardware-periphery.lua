local u = require("lua.utils")

--------------------------------------------------------------------------------
-- USB WATCHER

-- Podcasts onto OpenSwim-Player
local podcastSyncScript = "./helpers/cp-podcasts.sh"
OpenSwimWatcher = hs.usb.watcher
	.new(function(device)
		if not (device.eventType == "added" and device.productName == "LC8234xx_17S EVK") then return end

		u.notify("⏳ Starting Podcast Sync…")
		hs.task
			.new(podcastSyncScript, function(exitCode, _, stdErr)
				local msg = exitCode == 0 and "✅ Podcast Sync" or "⚠️️ Podcast Sync" .. stdErr
				u.notify(msg)
			end)
			:start()
	end)
	:start()

-- External Harddrive used for backups
ExternalHarddriveWatcher = hs.usb.watcher
	.new(function(device)
		if not (device.eventType == "added") then return end
		u.notify("Mounted: " .. device.productName)

		local harddriveNames = {
			"ZY603 USB3.0 Device", -- Externe A
			"External Disk 3.0", -- Externe B
			"Elements 2621", -- Externe C
		}
		local isBackupDrive = u.tbl_contains(harddriveNames, device.productName)

		if isBackupDrive then
			u.app("WerTerm"):activate()
		else
			u.runWithDelays(1, function()
				local stdout, success =
					hs.execute([[df -h | grep -io "\s/Volumes/.*" | cut -c2- | head -n1]])
				if not success or not stdout then return end
				hs.open(u.trim(stdout))
			end)
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- WIFI WATCHER

-- Notify on state changes of the WiFi network
WifiWatcher = hs.wifi.watcher
	.new(function(_, event)
		local ssid = hs.wifi.currentNetwork() or "none"
		local msg = event .. ": " .. ssid
		u.notify("📶 " .. msg)
		-- at the office, log the network
		if u.isAtOffice() then
			local timestamp = tostring(os.date()):sub(5, -6)
			u.appendToFile("./HBS-WiFi.log", timestamp .. " – " .. msg)
		end
	end)
	:watchingFor({ "SSIDChange" })
	:start()

--------------------------------------------------------------------------------
-- BLUETOOTH

local M = {}

---notifies & writes reminder
---is low. Caveat: `hs.battery` seems to work only with Apple devices.
---@param msgWhere "SideNotes"|"notify" where the information on low battery level should be send. "Reminder"|"notify"
function M.batteryCheck(msgWhere)
	local warningLevel = 20
	local devices = hs.battery.privateBluetoothBatteryInfo()
	if not devices then return end
	for _, device in pairs(devices) do
		local percent = tonumber(device.batteryPercentSingle)
		if percent > warningLevel then return end
		local msg = device.name .. " Battery is low (" .. percent .. "%)"
		if msgWhere == "SideNotes" then
			hs.osascript.javascript(string.format(
				[[const sidenotes = Application("SideNotes");
				const folder = sidenotes.folders.byName("Base");
				sidenotes.createNote({ folder: folder, text: "%s" });]],
				msg
			))
			print("⚠️", msg)
		else
			u.notify("⚠️", msg)
		end
	end
end

return M
