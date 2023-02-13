require("lua.utils")
--------------------------------------------------------------------------------
local podcastSyncScript = "./helpers/cp-podcasts.sh"
local function openSwimAdded (device)
	if not(device.eventType == "added" and device.productName == "LC8234xx_17S EVK") then return end

	Notify ("⏳ Starting Podcast Sync…")
	hs.task.new(podcastSyncScript, function (exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
		if exitCode == 0 then
			Notify ("✅ podcast sync finished")
		else
			Notify("⚠️️ podcast sync error"..stdErr)
		end
	end):start()
end

OpenSwimWatcher = hs.usb.watcher.new(openSwimAdded):start()
