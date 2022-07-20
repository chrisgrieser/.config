require("utils")
require("twitterrific-iina")
require("private")
require("Discord")

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT UTILS

if isAtOffice() then
	baseLayout = hs.layout.maximized
else
	baseLayout = pseudoMaximized
end
wf = hs.window.filter
pseudoMaximized = {x=0, y=0, w=0.815, h=1}

function numberOfScreens()
	return #(hs.screen.allScreens())
end


--------------------------------------------------------------------------------
-- WINDOW BASE MOVEMENT & SIDEBARS

-- requires these two actiosn beeing installed:
-- https://directory.getdrafts.com/a/2BS
-- https://directory.getdrafts.com/a/2BR
function toggleDraftsSidebar (draftsWin)
	runDelayed(0.05, function ()
		local drafts_w = draftsWin:frame().w
		local screen_w = draftsWin:screen():frame().w
		if (drafts_w / screen_w > 0.6) then
			-- using URI scheme since they are more reliable than the menu item
			hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=show-sidebar")
		else
			hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=hide-sidebar")
		end
	end)
	-- repetitation for some rare cases with lag needed
	runDelayed(0.3, function ()
		local drafts_w = draftsWin:frame().w
		local screen_w = draftsWin:screen():frame().w
		if (drafts_w / screen_w > 0.6) then
			-- using URI scheme since they are more reliable than the menu item
			hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=show-sidebar")
		else
			hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=hide-sidebar")
		end
	end)
end

function toggleHighlightsSidebar (highlightsWin)
	runDelayed(0.3, function ()
		local drafts_w = highlightsWin:frame().w
		local screen_w = highlightsWin:screen():frame().w
		if (drafts_w / screen_w > 0.6) then
			hs.application("Highlights"):selectMenuItem({"View", "Show Sidebar"})
		else
			hs.application("Highlights"):selectMenuItem({"View", "Hide Sidebar"})
		end
	end)
end

-- requires Obsidian Sidebar Toggler Plugin
-- https://github.com/chrisgrieser/obsidian-sidebar-toggler
function toggleObsidianSidebar (obsiWin)
	runDelayed(0.05, function ()
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
	end)
	runDelayed(0.3, function ()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if (numberOfObsiWindows > 1) then return end

		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w
		if (obsi_width / screen_width > 0.6) then
			hs.urlevent.openURL("obsidian://sidebar?side=left&show=true")
		else
			hs.urlevent.openURL("obsidian://sidebar?side=left&show=false")
		end
	end)
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
		position = pseudoMaximized
	elseif (direction == "maximized") then
		position = hs.layout.maximized
	elseif (direction == "centered") then
		position = {x=0.2, y=0.1, w=0.6, h=0.8}
	end

	-- workaround for https://github.com/Hammerspoon/hammerspoon/issues/2316
	resizingWorkaround(win, position)

	if win:application():name() == "Drafts" then toggleDraftsSidebar(win)
	elseif win:application():name() == "Obsidian" then toggleObsidianSidebar(win)
	elseif win:application():name() == "Highlights" then toggleHighlightsSidebar(win)
	end
end

function resizingWorkaround(win, pos)
	-- replaces `win:moveToUnit(pos)`

	win:moveToUnit(pos)
	-- has to repeat due to bug for some apps... :/
	hs.timer.delayed.new(0.3, function () win:moveToUnit(pos) end):start()
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
	if not(isIMacAtHome()) or isProjector() then return end

	local toTheSide = {x=0.815, y=0, w=0.185, h=1}

	openIfNotRunning("Discord")
	openIfNotRunning("Mimestream")
	openIfNotRunning("Slack")
	openIfNotRunning("Brave Browser")
	openIfNotRunning("Obsidian")
	openIfNotRunning("Twitterrific")
	openIfNotRunning("Drafts")

	killIfRunning("YouTube")
	killIfRunning("Netflix")
	killIfRunning("IINA")
	closeFinderWindows()
	closer()

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

	-- show sidebars
	runDelayed(0.5, function ()
		hs.layout.apply(homeLayout)
		hs.urlevent.openURL("drafts://x-callback-url/getCurrentDraft?x-success=drafts://open?showDraftList=true&uuid=")
		hs.urlevent.openURL("obsidian://sidebar?side=left&show=true")
		hs.application("Highlights"):selectMenuItem({"View", "Show Sidebar"})
	end)

	-- (redundancy to the discord launch, in case
	-- Discord launched while Hammerspoon wasn't active yet)
	discordWatcher("Discord", hs.application.watcher.launched)
	runDelayed(2.5, function ()
		-- delay necessary due to things triggered by Discord launch (see discord.lua)
		local slackWindowTitle = hs.application("Slack"):mainWindow():title()
		local slackUnreadMsg = slackWindowTitle:match("%*")
		if (slackUnreadMsg) then
			hs.application("Slack"):mainWindow():focus()
		else
			hs.application("Drafts"):focus()
		end
	end)
end

function officeModeLayout ()
	if not(isAtOffice()) then return end
	local screen1 = hs.screen.allScreens()[1]
	local screen2 = hs.screen.allScreens()[2]

	openIfNotRunning("Discord")
	openIfNotRunning("Mimestream")
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
	runDelayed(0.5, function ()
		hs.layout.apply(officeLayout)
		-- show sidebars
		hs.urlevent.openURL("drafts://x-callback-url/getCurrentDraft?x-success=drafts://open?showDraftList=true&uuid=")
		hs.urlevent.openURL("obsidian://sidebar?side=left&show=true")
		hs.application("Highlights"):selectMenuItem({"View", "Show Sidebar"})
	end)

	-- (redundancy to the discord launch, in case
	-- Discord launched while Hammerspoon wasn't active yet)
	discordWatcher("Discord", hs.application.watcher.launched)

	runDelayed(2.5, function ()
		-- delay necessary due to things triggered by Discord launch (see discord.lua)
		local slackWindowTitle = hs.application("Slack"):mainWindow():title()
		local slackUnreadMsg = slackWindowTitle:match("%*")
		if (slackUnreadMsg) then
			hs.application("Slack"):mainWindow():raise()
		end
	end)
end

--------------------------------------------------------------------------------
-- MULTI DISPLAY
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
-- gets the Windows on the main screen, in order of the stack
function mainScreenWindows()
	local winArr = hs.window.orderedWindows()
	local out = {}
	local j = 1
	local mainScreen = hs.screen.mainScreen()

	for i = 1, #winArr do
		if winArr[i]:screen() == mainScreen and winArr[i]:isStandard() then
			out[j] = winArr[i]
			j = j+1
		end
	end
	return out
end

-- Watcher, that raises win2 when win1 activates and vice versa. useful for splits
splitStatusMenubar = hs.menubar.new()
splitStatusMenubar:removeFromMenuBar() -- hide at beginning
function pairedActivation(start)
	if start then
		pairedWinWatcher = hs.application.watcher.new(function (_, eventType)
			if eventType == hs.application.watcher.activated then
				local currentWindow = hs.window.focusedWindow()
				if not(currentWindow) then return end
				if currentWindow:id() == WIN_RIGHT:id() then
					WIN_LEFT:raise() -- not using :focus(), since that causes infinite recursion
				elseif currentWindow:id() == WIN_LEFT:id() then
					WIN_RIGHT:raise()
				end
			elseif eventType == hs.application.watcher.terminated then
				vsplit("unsplit")
			end
		end)
		pairedWinWatcher:start()
		splitStatusMenubar:returnToMenuBar()
		splitStatusMenubar:setTitle("2️⃣")
	else
		pairedWinWatcher:stop()
		splitStatusMenubar:removeFromMenuBar()
	end
end

function vsplit (mode)
	local noSplitActive = true
	if WIN_RIGHT then splitExists = true end

	if noSplitActive and (mode == "switch" or mode == "unsplit") then
		notify ("No split active")
		return
	end

	if mode == "split" and noSplitActive then
		local wins = mainScreenWindows()	-- to not split windows on second screen
		WIN_RIGHT = wins[1] -- save in global variables, so they are not garbage-collected
		WIN_LEFT = wins[2]
	end

	if (WIN_RIGHT:frame().x > WIN_LEFT:frame().x) then -- ensure that WIN_RIGHT is really the right
		local temp = WIN_RIGHT
		WIN_RIGHT = WIN_LEFT
		WIN_LEFT = temp
	end
	local f1 = WIN_RIGHT:frame()
	local f2 = WIN_LEFT:frame()

	if mode == "split" then
		pairedActivation(true)
		local max = hs.screen.mainScreen():frame()
		if (f1.w ~= f2.w or f1.w > 0.7*max.w) then
			f1 = hs.layout.left50
			f2 = hs.layout.right50
		else
			f1 = hs.layout.left70
			f2 = hs.layout.right30
		end
	elseif mode == "unsplit" then
		pairedActivation(false)
		f1 = baseLayout
		f2 = baseLayout
	elseif mode == "switch" then
		if (f1.w == f2.w) then
			f1 = hs.layout.right50
			f2 = hs.layout.left50
		else
			f1 = hs.layout.right30
			f2 = hs.layout.left70
		end
	end

	resizingWorkaround(WIN_RIGHT, f1)
	resizingWorkaround(WIN_LEFT, f2)
	WIN_RIGHT:raise()
	WIN_LEFT:raise()
	if WIN_RIGHT:application():name() == "Drafts" then toggleDraftsSidebar(WIN_RIGHT)
	elseif WIN_LEFT:application():name() == "Drafts" then toggleDraftsSidebar(WIN_LEFT) end
	if WIN_RIGHT:application():name() == "Obsidian" then toggleObsidianSidebar(WIN_RIGHT)
	elseif WIN_LEFT:application():name() == "Obsidian" then toggleObsidianSidebar(WIN_LEFT) end
	if WIN_RIGHT:application():name() == "Highlights" then toggleHighlightsSidebar(WIN_RIGHT)
	elseif WIN_LEFT:application():name() == "Highlights" then toggleHighlightsSidebar(WIN_LEFT) end

	if mode == "unsplit" then
		WIN_RIGHT = nil
		WIN_LEFT = nil
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
hotkey(hyper, "C", function() vsplit("unsplit") end)
hotkey(hyper, "V", function()
	if (frontapp() == "Finder") then
		finderVsplit()
	else
		vsplit("split")
	end
end)

--------------------------------------------------------------------------------
-- WINDOW FILTERS & WINDOW FIXES
-- - https://www.hammerspoon.org/go/#winfilters
-- - https://github.com/dmgerman/hs_select_window.spoon/blob/main/init.lua

wf_browser = wf.new("Brave Browser")
wf_browser:subscribe(wf.windowCreated, function ()
	-- split when second window is opened
	if #wf_browser:getWindows() == 2 then
		local win1 = wf_browser:getWindows()[1]
		local win2 = wf_browser:getWindows()[2]
		resizingWorkaround(win1, hs.layout.left50)
		resizingWorkaround(win2, hs.layout.right50)
	end
end)

wf_browser:subscribe(wf.windowDestroyed, function ()
	-- Automatically hide Browser when no window
	if #wf_browser:getWindows() == 0 then
		hs.application("Brave Browser"):hide()

	-- change sizing back, when back to one window
	elseif #wf_browser:getWindows() == 1 then
		local win = wf_browser:getWindows()[1]
		resizingWorkaround(win, baseLayout)
	end
end)

-- Automatically hide Finder when no window
wf_finder = wf.new("Finder")
wf_finder:subscribe(wf.windowDestroyed, function ()
	if #wf_finder:getWindows() == 0 then
		hs.application("Finder"):hide()
	end
end)

-- keep Twitterrific visible
function twitterrificNextToPseudoMax(_, eventType)
	if not(eventType == hs.application.watcher.activated or eventType == hs.application.watcher.launching) then return end
	local currentWindow = hs.window.focusedWindow()
	if not(currentWindow) then return end
	if (WIN_LEFT == currentWindow) or (WIN_RIGHT == currentWindow) then return end

	local max = hs.screen.mainScreen():frame()
	local dif = currentWindow:frame().w - pseudoMaximized.w*max.w
	if dif < 10 and dif > -10 then
		hs.application("Twitterrific"):mainWindow():raise()
	end
end

anyAppActivationWatcher = hs.application.watcher.new(twitterrificNextToPseudoMax)
anyAppActivationWatcher:start()
