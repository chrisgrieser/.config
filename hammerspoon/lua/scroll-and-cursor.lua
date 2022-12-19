require("lua.utils")
--------------------------------------------------------------------------------

local function pseudoHideCursor()
	-- local screen = hs.mouse.getCurrentScreen()
	-- if not screen then return end
	-- local pos = {
	-- 	-- x = screen:frame().w - 1, -- -1 to keep it on the current screen
	-- 	x = 0,
	-- 	y = screen:frame().h * 0.75,
	-- }
	-- hs.mouse.setRelativePosition(pos, screen)
	keystroke({"alt", "ctrl"}, "k") -- hide cursor with cursorcerer
end

--------------------------------------------------------------------------------

-- HIGHLIGHTS Scroll
local highlightsScrollAmount = 20
local function highlightsAppScroll(amount)
	local highlightsWin = hs.application("Highlights"):mainWindow():frame()
	local centerPos = {
		x = highlightsWin.x + highlightsWin.w * 0.5,
		y = highlightsWin.y + highlightsWin.h * 0.5,
	}
	hs.mouse.setRelativePosition(centerPos)
	hs.eventtap.scrollWheel({ 0, amount }, {})
	pseudoHideCursor()
end

local function scrollDown()
	if frontAppName():lower() == "alacritty" then
		keystroke({ "shift" }, "pagedown")
	elseif frontAppName() == "Highlights" then
		highlightsAppScroll(-highlightsScrollAmount)
	else
		keystroke({}, "pagedown")
	end
end
local function scrollUp()
	if frontAppName():lower() == "alacritty" then
		keystroke({ "shift" }, "pageup")
	elseif frontAppName() == "Highlights" then
		highlightsAppScroll(highlightsScrollAmount)
	else
		keystroke({}, "pageup")
	end
end

hotkey({ "alt" }, "J", scrollDown, nil, scrollDown)
hotkey({ "alt" }, "K", scrollUp, nil, scrollUp)

--------------------------------------------------------------------------------

-- CURSOR HIDING in Brave
-- when Brave activates and j or k is pressed for the first time, hide cursor
local function hideCurAndPassThrough(key)
	jHidesCursor:disable() -- so it only works the first time
	kHidesCursor:disable()
	keystroke({}, key, 1) -- sending globally instead of to Brave, so it still works with Alfred
	pseudoHideCursor()
end

jHidesCursor = hotkey({}, "j", function() hideCurAndPassThrough("j") end):disable()
kHidesCursor = hotkey({}, "k", function() hideCurAndPassThrough("k") end):disable()

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
