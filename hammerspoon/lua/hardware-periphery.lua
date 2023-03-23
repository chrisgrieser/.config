require("lua.utils")

--------------------------------------------------------------------------------
-- BLUETOOTH

---notifies & writes to Drafts if battery level of a connected Bluetooth device
---is low. Caveat: `hs.battery` seems to work only with Apple devices.
---@param msgWhere string where the information on low battery level should be send. "Drafts"|"notify"
function PeripheryBatteryCheck(msgWhere)
	local warningLevel = 20
	local devices = hs.battery.privateBluetoothBatteryInfo()
	if not devices then return end

	for _, device in pairs(devices) do
		local percent = tonumber(device.batteryPercentSingle)
		if percent < warningLevel then
			local msg = device.name .. " Battery is low (" .. percent .. "%)"
			if msgWhere == "Drafts" then
				local draftsInbox = os.getenv("HOME")
					.. "/Library/Mobile Documents/iCloud~com~agiletortoise~Drafts5/Documents/Inbox/battery.md"
				WriteToFile(draftsInbox, msg)
				print("⚠️", msg)
			else
				Notify("⚠️", msg)
			end
		end
	end
end

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
ExternalHarddriveWatcher = hs.usb.watcher
	.new(function(device)
		if not (device.eventType == "added") then return end
		Notify("Mounted: " .. device.productName)

		local harddriveNames = {
			"ZY603 USB3.0 Device", -- Externe A
			-- "", TODO write down the name I get my hands on it again
			"Elements 2621", -- Externe C
		}
		local isBackupDrive = TableContains(harddriveNames, device.productName)
		
		if isBackupDrive then
			OpenApp("alacritty")
			AsSoonAsAppRuns("alacritty", function() hs.eventtap.keyStrokes("bkp") end)
		else
			local stdout, success = hs.execute([[df -h | grep -io "\s/Volumes/.*" | cut -c2- | head -n1]])
			if not success or not stdout then return end
			hs.open(Trim(stdout))
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
		Notify("📶 " .. msg)
		if IsAtOffice() then
			local timestamp = tostring(os.date()):sub(5, -6)
			AppendToFile("./HBS-WiFi.log", timestamp .. " – " .. msg)
		end
	end)
	:watchingFor({ "SSIDChange" })
	:start()
