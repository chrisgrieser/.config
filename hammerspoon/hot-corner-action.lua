-- CURRENTLY INACTIVE
--------------------------------------------------------------------------------

-- HOT CORNER Use "Quick Note" as Pseudo Hot Corner Action
-- to trigger something else instead
hs.execute("defaults write com.apple.dock wvous-br-corner -int 14")
function hotcornerWatcher(appName, eventType)
	if not(eventType == aw.activated and appName == "Notes") then return end

	hs.application("Notes"):kill9()
	hs.shortcuts.run("Keyboard on-screen")
end
hotcornerEmulation = hs.application.watcher.new(hotcornerWatcher)
hotcornerEmulation:start()

-- function listShortcuts()
-- 	local shortcuts = hs.shortcuts.list()
-- 	for i = 1, #shortcuts do
-- 		shortcuts[i].text = shortcuts[i].name
-- 		shortcuts[i].name = nil
-- 	end
-- 	return shortcuts
-- end

-- shortcutsChooser = hs.chooser.new(function(selectedItem)
-- 	hs.shortcuts.run(selectedItem.text)
-- 	notify (selectedItem.text)
-- end)
-- shortcutsChooser:choices(listShortcuts)

