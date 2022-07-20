-- CURRENTLY INACTIVE
--------------------------------------------------------------------------------

-- HOT CORNER Use "Quick Note" as Pseudo Hot Corner Action
-- to trigger something else instead
function hotcornerWatcher(appName, eventType)
	if (eventType == hs.application.watcher.activated) then
		if (appName == "Notes") then
			hs.application("Notes"):kill9()
			hs.shortcuts.run("Keyboard on-screen")
		end
	end
end
hotcornerEmulation = hs.application.watcher.new(hotcornerWatcher)
hotcornerEmulation:start()
