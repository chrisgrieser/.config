require("lua.utils")

highlightsScrollAmount = 20

--------------------------------------------------------------------------------
-- global pageup/down keys
-- have to be done here, since when send from Karabiner, gets caught by the
-- pagedown/up listener from Hammerspoon in `twitterific-iina.lua`

function pseudoHideCursor ()
	local screen = hs.mouse.getCurrentScreen()
	local pos = {
		x = screen:frame().w - 1, -- -1 to keep it on the current screen
		y = screen:frame().h * 0.75,
	}
	hs.mouse.setRelativePosition(pos, screen)
end

function scrollDown ()
	if frontapp():lower() == "alacritty" or frontapp() == "Terminal" then
		keystroke ({"shift"}, "pagedown")
	elseif frontapp() == "Highlights" then
		highlightsAppScroll(-highlightsScrollAmount)
	else
		keystroke ({}, "pagedown")
	end
end
function scrollUp ()
	if frontapp():lower() == "alacritty" or frontapp() == "Terminal" then
		keystroke ({"shift"}, "pageup")
	elseif frontapp() == "Highlights" then
		highlightsAppScroll(highlightsScrollAmount)
	else
		keystroke ({}, "pageup")
	end
end

hotkey({"alt"}, "J", scrollDown, nil, scrollDown)
hotkey({"alt"}, "K", scrollUp, nil, scrollUp)

--------------------------------------------------------------------------------

-- HIGHLIGHTS Scroll
function highlightsAppScroll (amount)
	local highlightsWin = hs.application("Highlights"):mainWindow():frame()
	local centerPos = {
		x = highlightsWin.x + highlightsWin.w * 0.5,
		y = highlightsWin.y + highlightsWin.h * 0.5,
	}
	hs.mouse.setRelativePosition(centerPos)

	hs.eventtap.scrollWheel({0, amount}, {})
	pseudoHideCursor()
end

-- CURSOR HIDING in Brave and Reeder
-- when activated and j/k is pressed for the first time, hide cursor
function hidingCursorInBrowser(key)
	jHidesCursor:disable() -- so it only works the first time
	kHidesCursor:disable()

	local frontmostApp = hs.application.frontmostApplication()
	keystroke({}, key, 1, frontmostApp)
	pseudoHideCursor()
end
jHidesCursor = hotkey({},"j", function() hidingCursorInBrowser("J") end)
kHidesCursor = hotkey({},"k", function() hidingCursorInBrowser("K") end)
jHidesCursor:disable()
kHidesCursor:disable()

function jkWatcher(appName, eventType)
	if (eventType == aw.activated) then
		if appName == "Brave Browser" or appName == "Reeder" or appName == "Inoreader" then
			jHidesCursor:enable()
			kHidesCursor:enable()
		else
			jHidesCursor:disable()
			kHidesCursor:disable()
		end
	end
end
jk_watcher = aw.new(jkWatcher)
jk_watcher:start()
