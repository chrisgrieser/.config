require("lua.utils")
--------------------------------------------------------------------------------
---filter console entries, removing logging for enabling/disabling hotkeys or
---extention loading. HACK to fix https://www.reddit.com/r/hammerspoon/comments/11ao9ui/how_to_suppress_logging_for_hshotkeyenable/
local function cleanupConsole()
	local consoleOutput = tostring(hs.console.getConsole())
	local out = ""
	for line in string.gmatch(consoleOutput, "[^\n]+") do -- split by new lines
		if
			not (line:find("Warning:.*LuaSkin: hs.canvas:delete") or line:find("hotkey: .*abled hotkey"))
		then
			out = out .. line .. "\n"
		end
	end
	hs.console.setConsole(out)
end

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
	cleanupConsole()
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
			cleanupConsole()
		else
			JHidesCursor:disable()
			KHidesCursor:disable()
			cleanupConsole()
		end
	end
end):start()
