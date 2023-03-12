require("lua.utils")
-- INFO unused, using auto-hide cursor extension in the browser
--------------------------------------------------------------------------------

---"hides" the cursor by moving it to the bottom left
local function pseudoHideCursor()
	local screen = hs.mouse.getCurrentScreen()
	if not screen then return end
	local pos = {
		x = 0,
		y = screen:frame().h * 0.9,
	}
	hs.mouse.setRelativePosition(pos, screen)
end

-- CURSOR HIDING in Browser
-- when Browser activates and j or k is pressed for the first time, hide cursor
local function hideCurAndPassThrough(key)
	JHidesCursor:disable() -- so it only works the first time
	KHidesCursor:disable()
	CleanupConsole()
	pseudoHideCursor()
	Keystroke({}, key, 1) -- sending globally instead of to Browser, so it still works with Alfred
end

JHidesCursor = Hotkey({}, "j", function() hideCurAndPassThrough("j") end):disable()
KHidesCursor = Hotkey({}, "k", function() hideCurAndPassThrough("k") end):disable()

Jk_watcher = Aw.new(function(appName, eventType)
	if eventType == Aw.activated then
		if appName == "Vivaldi" then
			JHidesCursor:enable()
			KHidesCursor:enable()
			CleanupConsole()
		else
			JHidesCursor:disable()
			KHidesCursor:disable()
			CleanupConsole()
		end
	end
end):start()
