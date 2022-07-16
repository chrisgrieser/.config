require("utils")

function openSwimUSB (device)
	notify(device.eventType)
	if device.eventType == "added" then
		notify ("connected: "..device.productName)
	elseif device.eventType == "removed" then
		notify ("disconnected"..device.productName)
	end
end

openSwimWatcher = hs.usb.watcher.new(openSwimUSB)
openSwimWatcher:start()
