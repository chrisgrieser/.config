require("utils")

function openSwimAdded (device)
	if not(device.eventType == "added" and device.productName == "LC8234xx_17S EVK") then return end

	notify ("connected: openSwim")
end

openSwimWatcher = hs.usb.watcher.new(openSwimAdded)
openSwimWatcher:start()
