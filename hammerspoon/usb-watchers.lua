require("utils")

function openSwimAdded (device)
	if not(device.eventType == "added" and device.productName == "LC8234xx_17S EVK") then return end
	hs.execute([[
		PODCAST_LOCATION=~"/Library/Group Containers/243LU875E5.groups.com.apple.podcasts/Library/Cache/"
		rsync "$PODCAST_LOCATION"/*.mp3 "/Volumes/OpenSwim/"
	]])
	notify ("Podcasts moved.")
end

openSwimWatcher = hs.usb.watcher.new(openSwimAdded)
openSwimWatcher:start()
