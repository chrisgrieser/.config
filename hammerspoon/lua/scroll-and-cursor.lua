require("lua.utils")
--------------------------------------------------------------------------------

local function pseudoHideCursor()
	local screen = hs.mouse.getCurrentScreen()
	if not screen then return end
	local pos = {
		x = screen:frame().w - 1, -- -1 to keep it on the current screen
		y = screen:frame().h * 0.75,
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
	if frontAppName():lower() == "alacritty" or frontAppName() == "Terminal" then
		keystroke({ "shift" }, "pagedown")
	elseif frontAppName() == "Highlights" then
		highlightsAppScroll(-highlightsScrollAmount)
	else
		keystroke({}, "pagedown")
	end
end
local function scrollUp()
	if frontAppName():lower() == "alacritty" or frontAppName() == "Terminal" then
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

	-- if key == "Alfred" then -- wordaround necessary, since Alfred isn't considered a window
	-- 	applescript('tell application id "com.runningwithcrayons.Alfred" to search')
	-- 	return
	-- end

	keystroke({}, key, 1)
	pseudoHideCursor()
end

jHidesCursor = hotkey({}, "j", function() hideCurAndPassThrough("J") end):disable()
kHidesCursor = hotkey({}, "k", function() hideCurAndPassThrough("K") end):disable()

-- INFO registering this shortcut requires disabling cmd+space in the macOS keyboard
-- settings (requires temporarily enabling the hotkey to do so)
-- alfredDisablesJKCursorHider = hotkey({ "cmd" }, "space", function() hideCurAndPassThrough("Alfred") end):disable()

jk_watcher = aw.new(function(appName, eventType)
	if eventType == aw.activated then
		if appName == "Brave Browser" then
			jHidesCursor:enable()
			kHidesCursor:enable()
			-- alfredDisablesJKCursorHider:enable()
		else
			jHidesCursor:disable()
			kHidesCursor:disable()
			-- alfredDisablesJKCursorHider:disable()
		end
	end
end):start()
