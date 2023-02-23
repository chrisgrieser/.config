require("lua.utils")
--------------------------------------------------------------------------------

local function pseudoHideCursor()
	local screen = hs.mouse.getCurrentScreen()
	if not screen then return end
	local pos = {
		x = 0,
		y = screen:frame().h * 0.9,
	}
	hs.mouse.setRelativePosition(pos, screen)
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
	if FrontAppName():lower() == "alacritty" then
		Keystroke({ "shift" }, "pagedown")
	elseif FrontAppName() == "Highlights" then
		highlightsAppScroll(-highlightsScrollAmount)
	else
		Keystroke({}, "pagedown")
	end
end
local function scrollUp()
	if FrontAppName():lower() == "alacritty" then
		Keystroke({ "shift" }, "pageup")
	elseif FrontAppName() == "Highlights" then
		highlightsAppScroll(highlightsScrollAmount)
	else
		Keystroke({}, "pageup")
	end
end

Hotkey({ "alt" }, "J", scrollDown, nil, scrollDown)
Hotkey({ "alt" }, "K", scrollUp, nil, scrollUp)

--------------------------------------------------------------------------------

-- CURSOR HIDING in Brave
-- when Brave activates and j or k is pressed for the first time, hide cursor
local function hideCurAndPassThrough(key)
	JHidesCursor:disable() -- so it only works the first time
	KHidesCursor:disable()
	Keystroke({}, key, 1) -- sending globally instead of to Brave, so it still works with Alfred
	pseudoHideCursor()
end

JHidesCursor = Hotkey({}, "j", function() hideCurAndPassThrough("j") end):disable()
KHidesCursor = Hotkey({}, "k", function() hideCurAndPassThrough("k") end):disable()

Jk_watcher = hs.application.watcher.new(function(appName, eventType)
	if eventType == hs.application.watcher.activated then
		if appName == "Vivaldi" then
			JHidesCursor:enable()
			KHidesCursor:enable()
		else
			JHidesCursor:disable()
			KHidesCursor:disable()
		end
	end
end):start()
