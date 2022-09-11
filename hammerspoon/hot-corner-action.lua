-- CURRENTLY INACTIVE
--------------------------------------------------------------------------------

-- HOT CORNER Use "Quick Note" as Pseudo Hot Corner Action

-- REQUIREMENTS:
-- - hs.execute("defaults write com.apple.dock wvous-br-corner -int 14")
-- - only Accessibility Keyboard being enabled in the Accessibility Shortcuts

function hotcornerWatcher(appName, eventType)
	if not(eventType == aw.activated and appName == "Notes") then return end

	hs.application("Notes"):kill9()
	-- using hs.eventtap.keyStroke somehow does not seem to work properly
	-- triggering via  Shotcuts ro menubar Gui also does not seem to be reliable
	hs.osascript.applescript('tell application "System Events" to key code 96 using {command down, option down}')
end
hotcornerEmulation = hs.application.watcher.new(hotcornerWatcher)
hotcornerEmulation:start()
