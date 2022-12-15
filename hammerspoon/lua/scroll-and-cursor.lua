require("lua.utils")

local highlightsScrollAmount = 20

--------------------------------------------------------------------------------
-- global pageup/down keys
-- have to be done here, since when send from Karabiner, gets caught by the
-- pagedown/up listener from Hammerspoon in `twitterific-iina.lua`

local function pseudoHideCursor ()
	local screen = hs.mouse.getCurrentScreen()
	if not(screen) then return end
	local pos = {
		x = screen:frame().w - 1, -- -1 to keep it on the current screen
		y = screen:frame().h * 0.75,
	}
	hs.mouse.setRelativePosition(pos, screen)
end

--------------------------------------------------------------------------------

-- HIGHLIGHTS Scroll
local function highlightsAppScroll (amount)
	local highlightsWin = hs.application("Highlights"):mainWindow():frame()
	local centerPos = {
		x = highlightsWin.x + highlightsWin.w * 0.5,
		y = highlightsWin.y + highlightsWin.h * 0.5,
	}
	hs.mouse.setRelativePosition(centerPos)
	hs.eventtap.scrollWheel({0, amount}, {})
	pseudoHideCursor()
end


local function scrollDown ()
	if frontApp():lower() == "alacritty" or frontApp() == "Terminal" then
		keystroke ({"shift"}, "pagedown")
	elseif frontApp() == "Highlights" then
		highlightsAppScroll(-highlightsScrollAmount)
	else
		keystroke ({}, "pagedown")
	end
end
local function scrollUp ()
	if frontApp():lower() == "alacritty" or frontApp() == "Terminal" then
		keystroke ({"shift"}, "pageup")
	elseif frontApp() == "Highlights" then
		highlightsAppScroll(highlightsScrollAmount)
	else
		keystroke ({}, "pageup")
	end
end

hotkey({"alt"}, "J", scrollDown, nil, scrollDown)
hotkey({"alt"}, "K", scrollUp, nil, scrollUp)

--------------------------------------------------------------------------------

-- CURSOR HIDING in Brave
-- when Brave activates and j or k is pressed for the first time, hide cursor
local function hideCurAndPassThrough(key)
	jHidesCursor:disable() -- so it only works the first time
	kHidesCursor:disable()
	keystroke({}, key, 1, hs.application("Brave Browser"))
	pseudoHideCursor()
end

jHidesCursor = hotkey({},"j", function() hideCurAndPassThrough("J") end):disable()
kHidesCursor = hotkey({},"k", function() hideCurAndPassThrough("K") end):disable()

jk_watcher = aw.new(function(appName, eventType)
	if eventType == aw.activated then
		if appName == "Brave Browser" then
			jHidesCursor:enable()
			kHidesCursor:enable()
		else
			jHidesCursor:disable()
			kHidesCursor:disable()
		end
	end
end):start()
