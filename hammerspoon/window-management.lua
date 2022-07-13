require("utils")
require("twitterrific-iina")
require("private")

--------------------------------------------------------------------------------
-- ACTIVE WINDOW HIGHLIGHT
-- => hammerspoon implementation of limelight https://github.com/koekeishiya/limelight

-- config
highlightDuration = 1.5
lightModeColor = hs.drawing.color.osx_yellow
darkModeColor = hs.drawing.color.green
lightModeStrokeWidth = 10
darkModeStrokeWidth = 7

function activeWindowHighlight(appName, eventType)
	if not(eventType == hs.application.watcher.activated or eventType == hs.application.watcher.launched) then return end

	-- Delete an existing highlight if it exists
	if rect then
		rect:delete() -- needed despite log message saying garbage collection takes care of it
		if rectTimer then
			rectTimer:stop()
		end
	end

	-- guard clauses
	if (appName == "IINA") then return end
	local win = hs.window.focusedWindow()
	if not (win) then return end
	local screenWidth = win:screen():frame().w
	local windowWidth = win:frame().w
	local windowRelativeWidth = windowWidth / screenWidth
	if (not(isAtOffice()) and windowRelativeWidth > 0.8) then return end

	local highlightColor
	local strokeWidth
	if isDarkMode() then
		highlightColor = darkModeColor
		strokeWidth = darkModeStrokeWidth
	else
		highlightColor = lightModeColor
		strokeWidth = lightModeStrokeWidth
	end

	local delayDuration = 0
	-- to account for finder window resizing
	if appName == "Finder" then delayDuration = 0.1 end
	runDelayed(delayDuration, function()
		rect = hs.drawing.rectangle(win:frame())
		rect:setStrokeWidth(strokeWidth)
		rect:setFill(false)
		rect:setStrokeColor(highlightColor)
		rect:show()
	end)

	rectTimer = runDelayed(highlightDuration, function()
		if rect then
			rect:delete()
			rect = nil
		end
	end)
end
appActivationWatcher = hs.application.watcher.new(activeWindowHighlight)
appActivationWatcher:start()

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

function toggleDraftsSidebar (draftsWin)
	local drafts_w = draftsWin:frame().w
	local screen_w = draftsWin:screen():frame().w
	if (drafts_w / screen_w > 0.6) then
		hs.application("Drafts"):selectMenuItem({"View", "Show Draft List"})
	else
		hs.application("Drafts"):selectMenuItem({"View", "Hide Draft List"})
	end
end

-- requires Obsidian Sidebar Toggler Plugin https://github.com/chrisgrieser/obsidian-sidebar-toggler
function toggleObsidianSidebar (obsiWin)
	-- prevent popout window resizing to affect sidebars
	local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
	if (numberOfObsiWindows > 1) then return end

	local obsi_width = obsiWin:frame().w
	local screen_width = obsiWin:screen():frame().w
	if (obsi_width / screen_width > 0.6) then
		hs.urlevent.openURL("obsidian://sidebar?side=left&show=true")
	else
		hs.urlevent.openURL("obsidian://sidebar?side=left&show=false")
	end
end

function moveAndResize(direction)
	local win = hs.window.focusedWindow()
	local position

	if (direction == "left") then
		position = hs.layout.left50
	elseif (direction == "right") then
		position = hs.layout.right50
	elseif (direction == "up") then
		position = {x=0, y=0, w=1, h=0.5}
	elseif (direction == "down") then
		position = {x=0, y=0.5, w=1, h=0.5}
	elseif (direction == "pseudo-maximized") then
		position = {x=0, y=0, w=0.815, h=1}
	elseif (direction == "maximized") then
		position = hs.layout.maximized
	elseif (direction == "centered") then
		position = {x=0.2, y=0.1, w=0.6, h=0.8}
	end

	-- workaround for https://github.com/Hammerspoon/hammerspoon/issues/2316
	resizingWorkaround(win, position)

	if win:application():name() == "Drafts" then
		runDelayed(0.2, function () toggleDraftsSidebar(win)	end)
	end
	if win:application():name() == "Obsidian" then
		runDelayed(0.2, function () toggleObsidianSidebar(win)	end)
	end
end

function resizingWorkaround(win, pos)
	-- replaces `win:moveToUnit(pos)`

	local winApp = win:application():name()
	-- add Applescript-capable apps used to the if-condition below
	-- if (winApp == "Finder" or winApp == "Brave Browser" or winApp == "BusyCal" or winApp == "Safari") then
	if (false) then
		hs.osascript.applescript([[
			use framework "AppKit"
			set allFrames to (current application's NSScreen's screens()'s valueForKey:"frame") as list
			set max_x to item 1 of item 2 of item 1 of allFrames
			set max_y to item 2 of item 2 of item 1 of allFrames
			]] ..

			"set x to "..pos.x .." * max_x\n" ..
			"set y to "..pos.y .." * max_y\n" ..
			"set w to "..pos.w .." * max_x\n" ..
			"set h to "..pos.h .." * max_y\n" ..
			'tell application "'..winApp..'" to set bounds of front window to {x, y, x + w, y + h}'
		)
	else
		win:moveToUnit(pos)
		-- has to repeat due to bug for some apps... :/
		hs.timer.delayed.new(0.3, function () win:moveToUnit(pos) end):start()
	end
end

--------------------------------------------------------------------------------
-- LAYOUTS & DISPLAYS

function movieModeLayout()
	if not(isProjector()) then return end
	local iMacDisplay = hs.screen.allScreens()[2]
	iMacDisplay:setBrightness(0)

	openIfNotRunning("YouTube")

	killIfRunning("Obsidian")
	killIfRunning("Drafts")
	killIfRunning("Slack")
	killIfRunning("Discord")
	killIfRunning("Mimestream")
	killIfRunning("Alfred Preferences")
	killIfRunning("Sublime Text")
	killIfRunning("alacritty")
	killIfRunning("Alacritty")

end

function homeModeLayout ()
	if not(isIMacAtHome()) then return end

	local pseudoMaximized = {x=0, y=0, w=0.815, h=1}
	local toTheSide = {x=0.815, y=0, w=0.185, h=1}

	openIfNotRunning("Mimestream")
	openIfNotRunning("Discord")
	openIfNotRunning("Slack")
	openIfNotRunning("Brave Browser")
	openIfNotRunning("Obsidian")
	openIfNotRunning("Twitterrific")
	openIfNotRunning("Drafts")

	killIfRunning("YouTube")
	killIfRunning("Netflix")
	killIfRunning("IINA")
	closeFinderWindows()

	hs.brightness.set(60)

	local screen = hs.screen.primaryScreen():name()
	local homeLayout = {
		{"Twitterrific", nil, screen, toTheSide, nil, nil},
		{"Brave Browser", nil, screen, pseudoMaximized, nil, nil},
		{"Sublime Text", nil, screen, pseudoMaximized, nil, nil},
		{"Slack", nil, screen, pseudoMaximized, nil, nil},
		{"Discord", nil, screen, pseudoMaximized, nil, nil},
		{"Obsidian", nil, screen, pseudoMaximized, nil, nil},
		{"Drafts", nil, screen, pseudoMaximized, nil, nil},
		{"Mimestream", nil, screen, pseudoMaximized, nil, nil},
		{"alacritty", nil, screen, pseudoMaximized, nil, nil},
		{"Alacritty", nil, screen, pseudoMaximized, nil, nil},
	}
	hs.layout.apply(homeLayout)

	runDelayed(0.5, function ()
		hs.layout.apply(homeLayout)
		hs.application("Drafts"):selectMenuItem({"View", "Show Draft List"})
	end)

	runDelayed(3, function ()
		-- delay necessary due to things triggered by Discord launch (see discord.lua)
		local slackWindowTitle = hs.application("Slack"):mainWindow():title()
		local slackUnreadMsg = slackWindowTitle:match("%*")
		if (slackUnreadMsg) then
			hs.application("Slack"):mainWindow():focus()
		else
			hs.application("Drafts"):mainWindow():focus()
		end
	end)

end

function officeModeLayout ()
	if not(isAtOffice()) then return end
	local screen1 = hs.screen.allScreens()[1]
	local screen2 = hs.screen.allScreens()[2]

	openIfNotRunning("Mimestream")
	openIfNotRunning("Discord")
	openIfNotRunning("Slack")
	openIfNotRunning("Brave Browser")
	openIfNotRunning("Obsidian")
	openIfNotRunning("Twitterrific")
	openIfNotRunning("Drafts")

	local maximized = hs.layout.maximized
	local bottom = {x=0, y=0.5, w=1, h=0.5}
	local topLeft = {x=0, y=0, w=0.515, h=0.5}
	local topRight = {x=0.51, y=0, w=0.49, h=0.5}

	local officeLayout = {
		{"Twitterrific", "@pseudo_meta - Home", screen2, topLeft, nil, nil},
		{"Twitterrific", "@pseudo_meta - List: _PKM & Obsidian Community", screen2, topRight, nil, nil},
		{"Discord", nil, screen2, bottom, nil, nil},
		{"Slack", nil, screen2, bottom, nil, nil},

		{"Brave Browser", nil, screen1, maximized, nil, nil},
		{"Sublime Text", nil, screen1, maximized, nil, nil},
		{"Obsidian", nil, screen1, maximized, nil, nil},
		{"Drafts", nil, screen1, maximized, nil, nil},
		{"Mimestream", nil, screen1, maximized, nil, nil},
		{"alacritty", nil, screen1, maximized, nil, nil},
		{"Alacritty", nil, screen1, maximized, nil, nil},
	}

	hs.layout.apply(officeLayout)
	runDelayed(0.3, function ()
		hs.layout.apply(officeLayout)
	end)
	runDelayed(0.6, function ()
		hs.layout.apply(officeLayout)
		hs.application("Drafts"):selectMenuItem({"View", "Show Draft List"})
	end)

	runDelayed(3, function ()
		-- delay necessary due to things triggered by Discord launch (see discord.lua)
		local slackWindowTitle = hs.application("Slack"):mainWindow():title()
		local slackUnreadMsg = slackWindowTitle:match("%*")
		if (slackUnreadMsg) then
			hs.application("Slack"):mainWindow():raise()
		else
			hs.application("Discord"):mainWindow():raise()
		end
	end)

end

function displayCountWatcher()
	if (isProjector()) then
		movieModeLayout()
	elseif (isIMacAtHome()) then
		homeModeLayout()
	end
end
displayWatcher = hs.screen.watcher.new(displayCountWatcher)
displayWatcher:start()

-- Open windows always on the screen where the mouse is
function moveWindowToMouseScreen(win)
	local mouseScreen = hs.mouse.getCurrentScreen()
	local screenOfWindow = win:screen()
	if (mouseScreen:name() == screenOfWindow:name()) then return end
	win:moveToScreen(mouseScreen)
end
function alwaysOpenOnMouseDisplay(appName, eventType, appObject)
	if not (isProjector()) then return end

	if (eventType == hs.application.watcher.launched) then
		-- delayed, to ensure window has launched properly
		runDelayed(0.5, function ()
			local appWindow = appObject:focusedWindow()
			moveWindowToMouseScreen(appWindow)
		end)
	elseif ((appName == "Brave Browser" or appName == "Finder") and hs.application.watcher.activated and isProjector()) then
		runDelayed(0.5, function ()
			local appWindow = appObject:focusedWindow()
			moveWindowToMouseScreen(appWindow)
		end)
	end
end
launchWhileMultiScreenWatcher = hs.application.watcher.new(alwaysOpenOnMouseDisplay)
if isIMacAtHome() then launchWhileMultiScreenWatcher:start() end

function moveToOtherDisplay ()
	local win = hs.window.focusedWindow()
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	-- workaround for ensuring proper resizing
	runDelayed(0.25, function ()
		win_ = hs.window.focusedWindow()
		win_:setFrameInScreenBounds(win_:frame())
	end)
end

--------------------------------------------------------------------------------
-- SPLITS
function mainScreenWindows()
	local winArr = hs.window.orderedWindows()
	local out = {}
	local j = 1
	local mainScreen = hs.screen.mainScreen()

	for i = 1, #winArr do
		if winArr[i]:screen() == mainScreen then
			out[j] = winArr[i]
			j = j+1
		end
	end
	return out
end

function vsplit (mode)
	local wins = mainScreenWindows()	-- to not split windows on second screen

	local win1 = wins[1]
	local win2 = wins[2]
	local f1 = win1:frame()
	local f2 = win2:frame()
	local max = win1:screen():frame()

	-- switch up, to ensure that win1 is the right one
	if (f1.x > f2.x) then
		local temp = win1
		win1 = win2
		win2 = temp
		f1 = win1:frame()
		f2 = win2:frame()
	end

	-- switch order of windows
	if mode == "switch" then
		if (f1.w + f2.w ~= max.w) then
			notify ("not a correct vertical split")
			return
		end
		if (f1.w == f2.w) then
			f1 = hs.layout.right50
			f2 = hs.layout.left50
		else
			f1 = hs.layout.right30
			f2 = hs.layout.left70
		end
	elseif mode == "split" then
		if (f1.w ~= f2.w or f1.w > 0.7*max.w) then
			f1 = hs.layout.left50
			f2 = hs.layout.right50
		else
			f1 = hs.layout.left70
			f2 = hs.layout.right30
		end
	elseif mode == "unsplit" then
		local layout
		if isAtOffice() then
			layout = hs.layout.maximized
		else
			layout = {x=0, y=0, w=0.815, h=1} -- pseudo-maximized
		end
		f1 = layout
		f2 = layout
	end

	resizingWorkaround(win1, f1)
	resizingWorkaround(win2, f2)

	if win1:application():name() == "Drafts" then
		runDelayed(0.2, function () toggleDraftsSidebar(win1)	end)
	elseif win2:application():name() == "Drafts" then
		runDelayed(0.2, function () toggleDraftsSidebar(win2)	end)
	end

	if win1:application():name() == "Obsidian" then
		runDelayed(0.2, function () toggleObsidianSidebar(win1) end)
	elseif win2:application():name() == "Obsidian" then
		runDelayed(0.2, function () toggleObsidianSidebar(win2) end)
	end

end

function finderVsplit ()
	hs.osascript.applescript([[
		use framework "AppKit"
		set allFrames to (current application's NSScreen's screens()'s valueForKey:"frame") as list
		set screenWidth to item 1 of item 2 of item 1 of allFrames
		set screenHeight to item 2 of item 2 of item 1 of allFrames

		set vsplit to {{0, 0, 0.5 * screenWidth, screenHeight}, {0.5 * screenWidth, 0, screenWidth, screenHeight} }

		tell application "Finder"
			if ((count windows) is 0) then return
			if ((count windows) is 1) then
				set currentWindow to target of window 1 as alias
				make new Finder window to folder currentWindow
			end if
			set bounds of window 1 to item 2 of vsplit
			set bounds of window 2 to item 1 of vsplit
		end tell
	]])
end

--------------------------------------------------------------------------------
-- HOTKEYS

hotkey(hyper, "Up", function() moveAndResize("up") end)
hotkey(hyper, "Down", function() moveAndResize("down") end)
hotkey(hyper, "Right", function() moveAndResize("right") end)
hotkey(hyper, "Left", function() moveAndResize("left") end)
hotkey(hyper, "Space", function() moveAndResize("maximized") end)
hotkey(hyper, "pagedown", function() moveToOtherDisplay() end)
hotkey(hyper, "pageup", function() moveToOtherDisplay() end)

hotkey(hyper, "home", function()
	if isAtOffice() then
		officeModeLayout()
	else
		homeModeLayout()
	end
	twitterrificScrollUp()
end)

hotkey({"ctrl"}, "Space", function ()
	if (frontapp() == "Finder") then
		moveAndResize("centered")
	elseif isAtOffice() then
		moveAndResize("maximized")
	else
		moveAndResize("pseudo-maximized")
	end
end)

hotkey(hyper, "X", function() vsplit("switch") end)
hotkey(hyper, "U", function() vsplit("unsplit") end)
hotkey(hyper, "V", function()
	if (frontapp() == "Finder") then
		finderVsplit()
	else
		vsplit("split")
	end
end)

