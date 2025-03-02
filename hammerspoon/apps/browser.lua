local M = {} -- persist from garbage collector

local u = require("meta.utils")
local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- VIMIUM CURSOR HIDER
-- Companion for Vimium-like browser extensions which are not able to hide the
-- cursor properly

---when Browser activates and j or k is pressed for the first time, hide cursor
---@param key string character that triggers cursor hiding
local function hideCurAndPassThrough(key)
	-- disable so it works only once
	M.hotkey_jHidesCursor:disable()
	M.hotkey_kHidesCursor:disable()

	-- FIX vimium not working until other browser hotkeys were used
	hs.eventtap.keyStroke({ "cmd" }, "t")
	hs.eventtap.keyStroke({ "cmd" }, "w")

	-- hide the cursor
	local screen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
	local bottomLeftPos = { x = 0, y = screen:frame().h * 0.9 }
	hs.mouse.setRelativePosition(bottomLeftPos, screen)

	-- pass through the key pressed
	hs.eventtap.keyStroke({}, key, 1)
end

M.hotkey_jHidesCursor = hs.hotkey.bind({}, "j", function() hideCurAndPassThrough("j") end):disable()
M.hotkey_kHidesCursor = hs.hotkey.bind({}, "k", function() hideCurAndPassThrough("k") end):disable()

-- watches browser, enables when hotkeys when browser is activated
M.aw_jkHotkeys = aw.new(function(appName, eventType)
	if eventType ~= aw.activated then return end

	if appName == "Brave Browser" then
		M.hotkey_jHidesCursor:enable()
		M.hotkey_kHidesCursor:enable()
	else
		M.hotkey_jHidesCursor:disable()
		M.hotkey_kHidesCursor:disable()
	end
end):start()

--------------------------------------------------------------------------------
-- BOOKMARKS SYNCED TO CHROME BOOKMARKS
-- so Alfred can pick up the Bookmarks without extra keyword

-- INFO The pathwatcher is triggered by changes of the *target*, while this
-- function touches the *symlink itself* due to `-h`. Thus, there is no need to
-- configure the symlink target here.

local chromeBookmarks = os.getenv("HOME")
	.. "/Library/Application Support/Google/Chrome/Default/Bookmarks"
local function touchSymlink() hs.execute(("touch -h %q"):format(chromeBookmarks)) end

-- sync on system start & when bookmarks are changed
if u.isSystemStart() then touchSymlink() end
M.pathw_bookmarks = hs.pathwatcher.new(chromeBookmarks, touchSymlink):start()

--------------------------------------------------------------------------------
return M
