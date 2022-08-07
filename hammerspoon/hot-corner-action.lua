-- CURRENTLY INACTIVE
--------------------------------------------------------------------------------

-- HOT CORNER Use "Quick Note" as Pseudo Hot Corner Action
-- to trigger something else instead
function hotcornerWatcher(appName, eventType)
	if (eventType == hs.application.watcher.activated) then
		if (appName == "Notes") then
			hs.application("Notes"):kill9()
			shortcutsChooser:show()
		end
	end
end
hotcornerEmulation = hs.application.watcher.new(hotcornerWatcher)
hotcornerEmulation:start()

function listShortcuts()
	local shortcuts = hs.shortcuts.list()
	for i = 1, #shortcuts do
		shortcuts[i].text = shortcuts[i].name
		shortcuts[i].name = nil
	end
	return shortcuts
end

shortcutsChooser = hs.chooser.new(function(selectedItem)
	hs.shortcuts.run(selectedItem.text)
	notify (selectedItem.text)
end)
shortcutsChooser:choices(listShortcuts)

