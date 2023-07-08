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

-- notify when new USB device is plugged in
-- if backup device: open terminal
-- otherwise: open volume
ExternalHarddriveWatcher = hs.usb.watcher
	.new(function(device)
		if not (device.eventType == "added") then return end
		local name = device.productName

		-- Docking Station in office does spammy reports
		if name == "Integrated RGB Camera" or name == "USB 10/100/1000 LAN" or name == "T27hv-20" then
			return
		end
		u.notify("Mounted: " .. name)

		local harddriveNames = {
			"ZY603 USB3.0 Device", -- Externe A
			"External Disk 3.0", -- Externe B
			"Elements 2621", -- Externe C
		}

		if u.tbl_contains(harddriveNames, name) then
			hs.application.open("WezTerm")
		else
			-- open volume
			u.runWithDelays({ 1, 2 }, function()
				local stdout, success =
					hs.execute([[df -h | grep -io "\s/Volumes/.*" | cut -c2- | head -n1]])
				if not success or not stdout then return end
				local path = stdout:gsub("\n", "")
				hs.open(path)
			end)
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- BLUETOOTH

---notifies & writes reminder
---is low. Caveat: `hs.battery` seems to work only with Apple devices.
local function batteryCheck()
	local warningLevel = 10
	local devices = hs.battery.privateBluetoothBatteryInfo()
	if not devices then return end

	for _, device in pairs(devices) do
		local percent = tonumber(device.batteryPercentSingle)
		if percent > warningLevel then return end
		local msg = device.name .. " Battery is low (" .. percent .. "%)"
		hs.osascript.javascript(([[Application("SideNotes").createNote({text: "%s"})]]):format(msg))
		print("⚠️", msg)
	end
end

--------------------------------------------------------------------------------
-- TRIGGERS

-- 1. System Start
if not u.isReloading() then batteryCheck() end

-- 2. daily
BiweeklyTimer = hs.timer
	.doAt("01:30", "01d", function()


	end, true)
	:start()
