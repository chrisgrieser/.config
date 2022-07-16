require("utils")
--------------------------------------------------------------------------------
podcastSyncScript = os.getenv("HOME").."/dotfiles/hammerspoon/cp-podcasts.sh"
function openSwimAdded (device)
	if not(device.eventType == "added" and device.productName == "LC8234xx_17S EVK") then return end

	notify ("⏳ Starting Podcast Sync…")
	hs.task.new(podcastSyncScript, function (exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
		if exitCode == 0 then
			notify ("✅ podcast sync finished")
			log("✅ podcast sync finished", "$HOME/dotfiles/Cron Jobs/some.log")
		else
			notify("⚠️️ podcast sync error"..stdErr)
			log("⚠️️ podcast sync error"..stdErr, "$HOME/dotfiles/Cron Jobs/some.log")
		end
	end):start()
end

openSwimWatcher = hs.usb.watcher.new(openSwimAdded)
openSwimWatcher:start()
