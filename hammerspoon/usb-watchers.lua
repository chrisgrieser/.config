require("utils")

function openSwimUSB (device)
	if device.eventType == "added" then
		notify ("connected: "..productName)
	elseif device.eventType == "removed" then
		notify ("disconnected"..productName)
	end
end

openSwimWatcher = hs.usb.watcher.new(openSwimUSB)
openSwimWatcher:start()
