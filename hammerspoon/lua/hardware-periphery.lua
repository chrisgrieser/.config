require("lua.utils")
--------------------------------------------------------------------------------
-- USB WATCHER

-- Podcasts onto OpenSwim-Player
local podcastSyncScript = "./helpers/cp-podcasts.sh"
OpenSwimWatcher = hs.usb.watcher
	.new(function(device)
		if not (device.eventType == "added" and device.productName == "LC8234xx_17S EVK") then return end

		Notify("⏳ Starting Podcast Sync…")
		hs.task
			.new(
				podcastSyncScript,
				function(exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
					local msg = exitCode == 0 and "✅ podcast sync finished"
						or "⚠️️ podcast sync error" .. stdErr
					Notify(msg)
				end
			)
			:start()
	end)
	:start()

-- External Harddrive used for backups
-- TODO add some more functionality later
ExternalHarddriveWatcher = hs.usb.watcher
	.new(function(device)
		if not (device.eventType == "added") then return end
		Notify("Mounted: " .. device.productName)

		local harddriveNames = {
			externe_A = "ZY603 USB3.0 Device",
			-- externe_B = "", TODO
			externe_C = "Elements 2621",
		}
		for _, productName in pairs(harddriveNames) do
			if productName == device.productName then OpenApp("Alacritty") end
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- WIFI WATCHER

-- Notify on state changes of the WiFi network
WifiWatcher = hs.wifi.watcher
	.new(function(_, msg)
		local ssid = hs.wifi.currentNetwork() or "none"
		Notify("WiFi (" .. msg .. "): " .. ssid)
	end)
	:watchingFor({ "SSIDChange", "modeChange", "powerChange" })
	:start()
