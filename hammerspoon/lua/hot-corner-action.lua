require("lua.utils")
-- CURRENTLY INACTIVE
--------------------------------------------------------------------------------

-- HOT CORNER 
-- Use "Quick Note" as Pseudo Hot Corner Action
-- Requirements:
-- - hs.execute("defaults write com.apple.dock wvous-br-corner -int 14")
-- - only Accessibility Keyboard being enabled in the Accessibility Shortcuts
local function hotcornerWatcher(appName, eventType)
	if not(eventType == Aw.activated and appName == "Notes") then return end

	App("Notes"):kill9()
	-- using hs.eventtap.keyStroke somehow does not seem to work properly
	-- triggering via shortcuts or menubar GUI also does not seem to be reliable
	Applescript('tell application "System Events" to key code 96 using {command down, option down}')
end
HotcornerEmulation = Aw.new(hotcornerWatcher):start()
