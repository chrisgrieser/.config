require("utils")

function openSwimAdded (device)
	if not(device.eventType == "added" and device.productName == "LC8234xx_17S EVK") then return end
	notify("device added.")
	hs.task.new(os.getenv("HOME").."/dotfiles/hammerspoon/cp-podcasts.sh", function (exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
		if exitCode == 0 then notify ("✅ podcast sync finished.")
		else notify("⚠️️ podcast sync error"..stdErr) end
	end):start()

end

openSwimWatcher = hs.usb.watcher.new(openSwimAdded)
openSwimWatcher:start()
