require("utils")

--------------------------------------------------------------------------------
-- global pageup/dwon keys
-- have to be done here, since when send from Karabiner, gets caught by the
-- pagedown/up listener from Hammerspoon in `twitterific-iina.lua`

function highlightsAppScroll (amount)
		-- has to be done via applescript, as repeated keystrokes
		-- via Hammerspoon have a slight lag
		local prevMousePos = hs.mouse.absolutePosition()

		-- center mouse on Highlights window
		local highlightsWin = hs.application("Highlights"):mainWindow():frame()
		local pos = {
			x = highlightsWin.x + highlightsWin.w * 0.5,
			y = highlightsWin.y + highlightsWin.h * 0.5,
		}
		hs.mouse.setRelativePosition(pos)

		hs.eventtap.scrollWheel({0, amount}, {})
		-- restore previous mouse position
		hs.mouse.absolutePosition(prevMousePos)
end

function scrollDown ()
	if frontapp():lower() == "alacritty" or frontapp() == "Terminal" then
		keystroke ({"shift"}, "pagedown")
	elseif frontapp() == "Highlights" then
		highlightsAppScroll(-13)
	else
		keystroke ({}, "pagedown")
	end
end
function scrollUp ()
	if frontapp():lower() == "alacritty" or frontapp() == "Terminal" then
		keystroke ({"shift"}, "pageup")
	elseif frontapp() == "Highlights" then
		highlightsAppScroll(13)
	else
		keystroke ({}, "pageup")
	end
end

hotkey({"alt"}, "J", scrollDown, nil, scrollDown)
hotkey({"alt"}, "K", scrollUp, nil, scrollUp)

--------------------------------------------------------------------------------
-- CURSOR HIDING
-- when Alacritty activates, hide cursor
-- when Brave activates and j or k is pressed for the first time, hide cursor
function hidingCursor(key)
	keystroke({}, key, 1, hs.application("Brave Browser"))
	local screen = hs.mouse.getCurrentScreen()
	local pos = {
		x = screen:frame().w - 1, -- -1 to keep it on the current screen
		y = screen:frame().h * 0.75,
	}
	hs.mouse.setRelativePosition(pos, screen)
	jHidesCursor:disable() -- so it only works the first time
	kHidesCursor:disable()
end
jHidesCursor = hotkey({},"j", function() hidingCursor("J") end)
kHidesCursor = hotkey({},"k", function() hidingCursor("K") end)
jHidesCursor:disable()
kHidesCursor:disable()

function jkWatcher(appName, eventType)
	if (eventType == hs.application.watcher.activated) then
		if (appName == "Brave Browser") then
			jHidesCursor:enable()
			kHidesCursor:enable()
		else
			jHidesCursor:disable()
			kHidesCursor:disable()
		end
		if (appName:lower() == "alacritty") then
			local screen = hs.mouse.getCurrentScreen()
			local pos = {
				x = screen:frame().w - 1, -- -1 to keep it on the current screen
				y = screen:frame().h * 0.75,
			}
			hs.mouse.setRelativePosition(pos, screen)
		end
	end
end
jk_watcher = hs.application.watcher.new(jkWatcher)
jk_watcher:start()
