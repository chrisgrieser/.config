require("lua.utils")
--------------------------------------------------------------------------------

local function scrollUp()
	if not (appIsRunning("Twitter")) then return end
	keystroke({ "shift", "command" }, "R", 1, app("Twitter")) -- reload
	-- needs delay to wait for tweet loading
	runWithDelays({ 0.2, 0.4, 0.6, 0.9, 1.2 }, function()
		keystroke({ "command" }, "1", 1, app("Twitter")) -- scroll up
		keystroke({ "command" }, "up", 1, app("Twitter")) -- goto top
	end)
end

-- TWITTER: fixed size to the side, with the sidebar hidden
twitterWatcher = aw.new(function(appName, eventType, appObj)
	-- move twitter and scroll it up
	if appName == "Twitter" and (eventType == aw.launched or eventType == aw.activated) then
		runWithDelays({ 0.05, 0.2 }, function()
			appObj:mainWindow():setFrame(toTheSide)
			scrollUp()
		end)

	-- auto-close media windows
	elseif appName == "Twitter" and eventType == aw.deactivated then
		local wins = appObj:allWindows()
		for _, win in pairs(wins) do
			if win:title() == "Media" then win:close() end
		end

	-- raise twitter
	elseif appIsRunning("Twitter") then
		local win = appObj:mainWindow()
		if checkSize(win, pseudoMaximized) and win:title() ~= "Quick Look" then
			app("Twitter"):mainWindow():raise()
		end
	end
end):start()

--------------------------------------------------------------------------------

local function moveCurWinToOtherDisplay()
	local win = hs.window.focusedWindow()
	if not win then return end
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	runWithDelays({ 0.1, 0.2 }, function()
		-- workaround for ensuring proper resizing
		win = hs.window.focusedWindow()
		if not win then return end
		win:setFrameInScreenBounds(win:frame())
	end)
end

local function pagedownAction()
	if #hs.screen.allScreens() > 1 then
		moveCurWinToOtherDisplay()
	elseif appIsRunning("Twitter") then
		keystroke({}, "down", 1, app("Twitter")) -- tweet down
	end
end

local function pageupAction()
	if #hs.screen.allScreens() > 1 then
		moveCurWinToOtherDisplay()
	elseif appIsRunning("Twitter") then
		keystroke({}, "up", 1, app("Twitter")) -- tweet up
	end
end

local function endAction()
	if appIsRunning("Twitter") then
		keystroke({ "command" }, "K", 1, app("Twitter")) -- open tweet
	end
end

local function homeAction()
	if appIsRunning("zoom.us") then
		alert("🔈/🔇") -- toggle mute
		keystroke({ "shift", "command" }, "A", 1, app("zoom.us"))
		return
	end
	scrollUp()
end

-- Hotkeys
hotkey({}, "f6", moveCurWinToOtherDisplay) -- for apple keyboard
hotkey({}, "pagedown", pagedownAction, nil, pagedownAction)
hotkey({}, "pageup", pageupAction, nil, pageupAction)
hotkey({}, "home", homeAction)
hotkey({}, "end", endAction)
