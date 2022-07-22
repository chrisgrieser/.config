require("utils")
require("twitterrific-iina")
require("private")
require("Discord")

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT UTILS
pseudoMaximized = {x=0, y=0, w=0.815, h=1}
maximized = hs.layout.maximized
wf = hs.window.filter
if isAtOffice() then
	baseLayout = maximized
else
	baseLayout = pseudoMaximized
end
iMacDisplay = hs.screen("Built%-in") -- % to escape hyphen repetition

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
			hs.urlevent.openURL("obsidian://sidebar?showLeft=true&showRight=false")
		else
			hs.urlevent.openURL("obsidian://sidebar?showLeft=false&showRight=false")
		end
	end)
	runDelayed(0.3, function ()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if (numberOfObsiWindows > 1) then return end

		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w
		if (obsi_width / screen_width > 0.6) then
			hs.urlevent.openURL("obsidian://sidebar?showLeft=true&showRight=false")
		else
			hs.urlevent.openURL("obsidian://sidebar?showLeft=false&showRight=false")
		end
	end)
end

function showAllSidebars ()
	hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=show-sidebar")
	hs.urlevent.openURL("obsidian://sidebar?showLeft=true&showRight=false")
	hs.application("Highlights"):selectMenuItem({"View", "Show Sidebar"})
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
		position = maximized
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

	local toTheSide = {x=0.815, y=0, w=0.185, h=1}
	local homeLayout = {
		{"Twitterrific", nil, iMacDisplay, toTheSide, nil, nil},
		{"Brave Browser", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Sublime Text", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Slack", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Discord", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Obsidian", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Drafts", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Mimestream", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"alacritty", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Alacritty", nil, iMacDisplay, pseudoMaximized, nil, nil},
	}

	hs.layout.apply(homeLayout)
	runDelayed(0.3, function ()
		hs.layout.apply(homeLayout)
		showAllSidebars()
		discordLaunch(false)
		hs.application("Drafts"):activate()
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
		showAllSidebars()
		discordLaunch(false)
		hs.application("Drafts"):activate()
	end)
	-- runDelayed(0.5, function ()
	-- 	hs.layout.apply(officeLayout)
	-- end)

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

	if (eventType == aw.launched) then
		-- delayed, to ensure window has launched properly
		runDelayed(0.5, function ()
			local appWindow = appObject:focusedWindow()
			moveWindowToMouseScreen(appWindow)
		end)
	elseif (appName == "Brave Browser" or appName == "Finder") and aw.activated and isProjector() then
		runDelayed(0.5, function ()
			local appWindow = appObject:focusedWindow()
			moveWindowToMouseScreen(appWindow)
		end)
	end
end
launchWhileMultiScreenWatcher = aw.new(alwaysOpenOnMouseDisplay)
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
		pairedWinWatcher = aw.new(function (_, eventType)
			if eventType == aw.activated then
				local currentWindow = hs.window.focusedWindow()
				if not(currentWindow) then return end
				if currentWindow:id() == SPLIT_RIGHT:id() then
					SPLIT_LEFT:raise() -- not using :focus(), since that causes infinite recursion
				elseif currentWindow:id() == SPLIT_LEFT:id() then
					SPLIT_RIGHT:raise()
				end
			elseif eventType == aw.terminated and (not(SPLIT_LEFT) or not(SPLIT_RIGHT)) then
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
	if SPLIT_RIGHT then noSplitActive = false end

	if noSplitActive and (mode == "switch" or mode == "unsplit") then
		notify ("No split active")
		return
	end

	if mode == "split" and noSplitActive then
		local wins = mainScreenWindows()	-- to not split windows on second screen
		SPLIT_RIGHT = wins[1] -- save in global variables, so they are not garbage-collected
		SPLIT_LEFT = wins[2]
	end

	if (SPLIT_RIGHT:frame().x > SPLIT_LEFT:frame().x) then -- ensure that WIN_RIGHT is really the right
		local temp = SPLIT_RIGHT
		SPLIT_RIGHT = SPLIT_LEFT
		SPLIT_LEFT = temp
	end
	local f1 = SPLIT_RIGHT:frame()
	local f2 = SPLIT_LEFT:frame()

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

	resizingWorkaround(SPLIT_RIGHT, f1)
	resizingWorkaround(SPLIT_LEFT, f2)
	SPLIT_RIGHT:raise()
	SPLIT_LEFT:raise()
	if SPLIT_RIGHT:application():name() == "Drafts" then toggleDraftsSidebar(SPLIT_RIGHT)
	elseif SPLIT_LEFT:application():name() == "Drafts" then toggleDraftsSidebar(SPLIT_LEFT) end
	if SPLIT_RIGHT:application():name() == "Obsidian" then toggleObsidianSidebar(SPLIT_RIGHT)
	elseif SPLIT_LEFT:application():name() == "Obsidian" then toggleObsidianSidebar(SPLIT_LEFT) end
	if SPLIT_RIGHT:application():name() == "Highlights" then toggleHighlightsSidebar(SPLIT_RIGHT)
	elseif SPLIT_LEFT:application():name() == "Highlights" then toggleHighlightsSidebar(SPLIT_LEFT) end

	if mode == "unsplit" then
		SPLIT_RIGHT = nil
		SPLIT_LEFT = nil
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
-- APP-SPECIFIC WINDOW BEHAVIOR
-- - https://www.hammerspoon.org/go/#winfilters
-- - https://github.com/dmgerman/hs_select_window.spoon/blob/main/init.lua

function isIncognitoWindow(browserWin)
	if browserWin:title():match("%(Private%)$") then return true
	else return false end
end

-- BROWSER
wf_browser = wf.new("Brave Browser")
wf_browser:subscribe(wf.windowCreated, function ()
	-- split when second window is opened
	if #wf_browser:getWindows() == 2 then
		local win1 = wf_browser:getWindows()[1]
		local win2 = wf_browser:getWindows()[2]
		if isIncognitoWindow(win1) or isIncognitoWindow(win2) then return end -- do not effect switch to inkognito windows
		resizingWorkaround(win1, hs.layout.left50)
		resizingWorkaround(win2, hs.layout.right50)
	end

	-- if new window is incognito window, position it to the left
	local currentWindow = hs.window.focusedWindow()
	if isIncognitoWindow(currentWindow) then
		resizingWorkaround(currentWindow, baseLayout)
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

-- Automatically hide FINDER when no window
wf_finder = wf.new("Finder")
wf_finder:subscribe(wf.windowDestroyed, function ()
	if #wf_finder:getWindows() == 0 then
		hs.application("Finder"):hide()
	end
end)

-- keep TWITTERRIFIC visible, when active window is pseudomaximized
function twitterrificNextToPseudoMax(_, eventType)
	if not(eventType == aw.activated or eventType == aw.launching) then return end
	local currentWindow = hs.window.focusedWindow()
	if not(currentWindow) then return end

	local max = hs.screen.mainScreen():frame()
	local dif = currentWindow:frame().w - pseudoMaximized.w*max.w
	if dif < 10 and dif > -10 then
		hs.application("Twitterrific"):mainWindow():raise()
	end
end
anyAppActivationWatcher = aw.new(twitterrificNextToPseudoMax)
anyAppActivationWatcher:start()

-- Minimize first Zoom Window, when second is open
wf_zoom = wf.new("zoom.us")
wf_zoom:subscribe(wf.windowCreated, function ()
	if #wf_zoom:getWindows() == 2 then
		runDelayed (1, function()
			hs.application("zoom.us"):findWindow("^Zoom$"):close()
		end)
	end
end)

-- SUBLIME
-- workaround for Window positioning issue, will be fixed with build 4130 being released - https://github.com/sublimehq/sublime_text/issues/5237
function sublimeLaunch(appName, eventType)
	if not(appName == "Sublime Text" and eventType == aw.launched) then return end

	if isAtOffice() then
		runDelayed(0.1, function () moveAndResize("maximized") end)
	else
		runDelayed(0.1, function () moveAndResize("pseudo-maximized") end)
		hs.application("Twitterrific"):mainWindow():raise()
	end
end
sublimeWatcher = aw.new(sublimeLaunch)
sublimeWatcher:start()

-- if new window is a settings window, maximize it
wf_sublime = wf.new("Sublime Text")
wf_sublime:subscribe(wf.windowCreated, function ()
	local currentWindow = hs.window.focusedWindow()
	if currentWindow:title():match("sublime%-settings$") then  -- % to escape hyphen repetition
		moveAndResize("maximized")
	end
end)
