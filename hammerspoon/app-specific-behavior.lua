require("utils")
require("window-management")
require("system-and-cron")

--------------------------------------------------------------------------------

-- always activate windows together
function allWindowsActivation(appName, eventType, appObject)
	if not(eventType == aw.activated) then return end
	if not(appName == "Finder" or appName == "Brave Browser" or appName == "Mimestream") then return end

	--don't interfere with split
	if SPLIT_RIGHT then ---@diagnostic disable-line: undefined-global
		if (appName == SPLIT_RIGHT:application():name() or SPLIT_LEFT:application():name()) then return end ---@diagnostic disable-line: undefined-global
	end

	appObject:selectMenuItem({"Window", "Bring All to Front"})
end
appWatcher = aw.new(allWindowsActivation)
appWatcher:start()

--------------------------------------------------------------------------------

-- OBSIDIAN
-- Sync on Vault close
function obsidianSync (appName, eventType)
	if not(eventType == aw.launching or eventType == aw.terminated) then return end
	if not(appName == "Obsidian") then return end
	gitVaultSync() ---@diagnostic disable-line: undefined-global
end

anyAppActivationWatcher = aw.new(obsidianSync )
anyAppActivationWatcher:start()

--------------------------------------------------------------------------------

-- BRAVE BROWSER
-- split when second window is opened
-- change sizing back, when back to one window
wf_browser = wf.new("Brave Browser"):setOverrideFilter{rejectTitles={" %(Private%)$","^Picture in Picture$", "^Task Manager$"}, allowRoles='AXStandardWindow', hasTitlebar=true}
wf_browser:subscribe(wf.windowCreated, function ()
	if #wf_browser:getWindows() == 1 then
		if isAtOffice() or isProjector() then
			moveResizeCurWin("maximized")
		else
			moveResizeCurWin("pseudo-maximized")
			hs.application("Twitterrific"):mainWindow():raise()
		end
	end
	if #wf_browser:getWindows() == 2 then
		local win1 = wf_browser:getWindows()[1]
		local win2 = wf_browser:getWindows()[2]
		moveResize(win1, hs.layout.left50)
		moveResize(win2, hs.layout.right50)
	end
end)
wf_browser:subscribe(wf.windowDestroyed, function ()
	if #wf_browser:getWindows() == 1 then
		local win = wf_browser:getWindows()[1]
		moveResize(win, baseLayout)
	end
end)

-- Automatically hide Browser when no window
wf_browser_all = wf.new("Brave Browser"):setOverrideFilter{allowRoles='AXStandardWindow'}
wf_browser_all:subscribe(wf.windowDestroyed, function ()
	if #wf_browser_all:getWindows() == 0 then
		hs.application("Brave Browser"):hide()
	end
end)

--------------------------------------------------------------------------------

-- MIMESTREAM
-- split when second window is opened
-- change sizing back, when back to one window
wf_mimestream = wf.new("Mimestream"):setOverrideFilter{allowRoles='AXStandardWindow', rejectTitles={"General", "Accounts", "Sidebar & List", "Viewing", "Composing", "Templates", "Signatures", "Labs"}}
wf_mimestream:subscribe(wf.windowCreated, function ()
	if #wf_mimestream:getWindows() == 2 then
		local win1 = wf_mimestream:getWindows()[1]
		local win2 = wf_mimestream:getWindows()[2]
		moveResize(win1, hs.layout.left50)
		moveResize(win2, hs.layout.right50)
	end
end)
wf_mimestream:subscribe(wf.windowDestroyed, function ()
	if #wf_mimestream:getWindows() == 1 then
		local win = wf_mimestream:getWindows()[1]
		moveResize(win, baseLayout)
	end
end)

--------------------------------------------------------------------------------

-- keep TWITTERRIFIC visible, when active window is pseudomaximized
function twitterrificNextToPseudoMax(_, eventType)
	if not(eventType == aw.activated or eventType == aw.launching) then return end
	if not (hs.application("Twitterrific")) then return end

	local currentWin = hs.window.focusedWindow()
	if isPseudoMaximized(currentWin) then
		hs.application("Twitterrific"):mainWindow():raise()
	end
end
anyAppActivationWatcher = aw.new(twitterrificNextToPseudoMax)
anyAppActivationWatcher:start()

--------------------------------------------------------------------------------

-- SUBLIME
wf_sublime = wf.new("Sublime Text"):setOverrideFilter{allowRoles='AXStandardWindow'}
wf_sublime:subscribe(wf.windowCreated, function (newWindow)
	-- if new window is a settings window, maximize it
	if newWindow:title():match("sublime%-settings$") or newWindow:title():match("sublime%-keymap$") then
		moveResizeCurWin("maximized")

	-- subl cli
	elseif newWindow:title() == "stdin" then
		moveResizeCurWin("centered")

	-- command-line-edit window = split with alacritty (using EDITOR='subl --new-window --wait')
	elseif newWindow:title():match("^zsh%w+$") then
		local alacrittyWin = hs.application("alacritty"):mainWindow()
		moveResize(alacrittyWin, hs.layout.left50)
		moveResize(newWindow, hs.layout.right50)
		newWindow:becomeMain() -- so cmd-tabbing activates this window and not any other one
		hs.osascript.applescript([[
			tell application "System Events"
				tell process "Sublime Text"
					click menu item "Bash" of menu of menu item "Syntax" of menu "View" of menu bar 1
				end tell
			end tell
		]])

	-- workaround for Window positioning issue, will be fixed with build 4130 being released
	-- https://github.com/sublimehq/sublime_text/issues/5237
	elseif isAtOffice() or isProjector() then
		moveResizeCurWin("maximized")
	else
		moveResizeCurWin("pseudo-maximized")
		hs.application("Twitterrific"):mainWindow():raise()
	end
end)
wf_sublime:subscribe(wf.windowDestroyed, function ()
	-- don't leave windowless app behind
	if #wf_sublime:getWindows() == 0 and appIsRunning("Sublime Text") then
		hs.application("Sublime Text"):kill()
	end
	-- editing command line finished
	if not(hs.application("alacritty")) then return end
	local alacrittyWin = hs.application("alacritty"):mainWindow()
	if isHalf(alacrittyWin) then
		moveResize(alacrittyWin, baseLayout)
		alacrittyWin:focus()
		keystroke({}, "space") -- to redraw zsh-syntax highlighting of the buffer
	end
end)
wf_sublime:subscribe(wf.windowFocused, function (focusedWin)
	-- editing command line: paired activation of both windows
	if not(appIsRunning("alacritty")) then return end
	local alacrittyWin = hs.application("alacritty"):mainWindow()
	if focusedWin:title():match("^zsh%w+$") and isHalf(alacrittyWin) then
		alacrittyWin:raise()
	end
end)

--------------------------------------------------------------------------------

-- ALACRITTY
wf_alacritty = wf.new("alacritty"):setOverrideFilter{rejectTitles={"^cheatsheet: "}}
wf_alacritty:subscribe(wf.windowCreated, function ()
	if isAtOffice() or isProjector() then
		moveResizeCurWin("maximized")
	else
		moveResizeCurWin("pseudo-maximized")
		hs.application("Twitterrific"):mainWindow():raise()
	end
end)

-- for nicer background pictures together with gransparency
wf_alacritty:subscribe(wf.windowFocused, function (focusedWindow)
	runDelayed (0.01, function ()
		wins = hs.window.orderedWindows() -- as opposed to :allWindows(), this *excludes* headless Twitterrific
		for i = 1, #wins do
			local app = wins[i]:application()
			if not(app:name() == "alacritty") then app:hide() end
		end
	end)
	if not(isPseudoMaximized(focusedWindow)) then
		hs.application("Twitterrific"):hide()
	end
end)
wf_alacritty:subscribe(wf.windowDestroyed, function ()
	keystroke({"cmd"}, "tab") -- to prevent empty window left behind
end)

-- ALACRITTY Man / cheat sheet leaader hotkey
-- work around necessary, cause alacritty creates multiple instances, i.e.
-- multiple applications all with the name "alacritty", preventing conventional
-- methods for focussing a window via AppleScript
hs.urlevent.bind("focus-help", function()
	local win = hs.window.find("man:")
	if not(win) then win = hs.window.find("builtin:") end
	if not(win) then win = hs.window.find("cheatsheet:") end

	if win then
		win:focus()
	else
		notify ("none open")
	end
end)

--------------------------------------------------------------------------------

-- FINDER: when activated
-- - Bring all windows forward
-- - hide sidebar
-- - enlarge window if it's too small
-- - quit Finder when no window
function finderWatcher(appName, eventType, appObject)
	if not(eventType == aw.activated and appName == "Finder") then return end

	appObject:selectMenuItem({"View", "Hide Sidebar"})

	local finderWin = appObject:focusedWindow()
	local isInfoWindow = finderWin:title():match(" Info$")
	if isInfoWindow then return end

	local win_h = finderWin:frame().h
	local max_h = finderWin:screen():frame().h
	local max_w = finderWin:screen():frame().w
	local target_w = 0.6 * max_w
	local target_h = 0.8 * max_h
	if (win_h / max_h) < 0.7 then
		finderWin:setSize({w = target_w, h = target_h})
	end
end
finderAppWatcher = aw.new(finderWatcher)
finderAppWatcher:start()

wf_finder = wf.new("Finder")
wf_finder:subscribe(wf.windowDestroyed, function ()
	if #wf_finder:getWindows() == 0 then
		-- not via kill, so in-progress-oprations do not get aborted
		hs.osascript.applescript('tell application "Finder" to quit')
	end
end)

-- MARTA
-- - (pseudo)maximize
-- - close other tabs when reopening
-- - quit Marta when no window remaining
wf_marta = wf.new("Marta"):setOverrideFilter{allowRoles='AXStandardWindow', rejectTitles="^Preferences$"}
wf_marta:subscribe(wf.windowCreated, function ()
	runDelayed(0.1, function () -- close other tabs, needed because: https://github.com/marta-file-manager/marta-issues/issues/896
		keystroke({"shift"}, "w", 1, hs.application("Marta"))
	end)
	if isAtOffice() or isProjector() then
		moveResizeCurWin("maximized")
	else
		moveResizeCurWin("pseudo-maximized")
		hs.application("Twitterrific"):mainWindow():raise()
	end
end)
wf_marta:subscribe(wf.windowDestroyed, function ()
	if #wf_marta:getWindows() == 0 then
		hs.application("Marta"):kill()
	end
end)

--------------------------------------------------------------------------------

-- ZOOM
-- close first window, when second is open
-- don't leave tab behind when opening zoom
wf_zoom = wf.new("zoom.us")
wf_zoom:subscribe(wf.windowCreated, function ()
	local numberOfZoomWindows = #wf_zoom:getWindows();
	if numberOfZoomWindows == 2 then
		runDelayed (1.3, function()
			hs.application("zoom.us"):findWindow("^Zoom$"):close()
		end)
	elseif numberOfZoomWindows == 1 then
		runDelayed(2, function ()
			hs.osascript.applescript([[
				tell application "Brave Browser"
					set window_list to every window
					repeat with the_window in window_list
						set tab_list to every tab in the_window
						repeat with the_tab in tab_list
							set the_url to the url of the_tab
							if the_url contains ("zoom.us") then
								close the_tab
							end if
						end repeat
					end repeat
				end tell
			]])
		end)
	end
end)

--------------------------------------------------------------------------------

-- HIGHLIGHTS:
-- - Sync Dark & Light Mode
-- - Start with Highlight as Selection
function highlightsWatcher(appName, eventType)
	if not(eventType == aw.launched and appName == "Highlights") then return end
	hs.osascript.applescript([[
		tell application "System Events"
			tell appearance preferences to set isDark to dark mode
			if (isDark is false) then set targetView to "Default"
			if (isDark is true) then set targetView to "Night"
			delay 0.4

			tell process "Highlights"
				set frontmost to true
				click menu item targetView of menu of menu item "PDF Appearance" of menu "View" of menu bar 1
				click menu item "Highlight" of menu "Tools" of menu bar 1
				click menu item "Yellow" of menu of menu item "Color" of menu "Tools" of menu bar 1
			end tell
		end tell
	]])
	if isAtOffice() then moveResizeCurWin("maximized")
	else moveResizeCurWin("pseudo-maximized") end
end
highlightsAppWatcher = aw.new(highlightsWatcher)
highlightsAppWatcher:start()

--------------------------------------------------------------------------------

-- DRAFTS: Hide Toolbar
function draftsLaunchWake(appName, eventType, appObject)
	if not(appName == "Drafts") then return end

	if (eventType == aw.launched) then
		runDelayed(0.5, function ()
			appObject:selectMenuItem({"View", "Hide Toolbar"})
		end)
	elseif (eventType == aw.activated) then
		appObject:selectMenuItem({"View", "Hide Toolbar"})
	end
end
draftsWatcher3 = aw.new(draftsLaunchWake)
draftsWatcher3:start()

--------------------------------------------------------------------------------

-- MACPASS: properly show when activated
function macPassActivate(appName, eventType, appObject)
	if not(appName == "MacPass") or not(eventType == aw.launched) then return end
	runDelayed(0.3, function () appObject:activate() end)
end
macPassWatcher = aw.new(macPassActivate)
macPassWatcher:start()

--------------------------------------------------------------------------------

-- YOUTUBE + SPOTIFY
-- Pause Spotify on launch
-- Resume Spotify on quit
function spotifyTUI (toStatus)
	local currentStatus = hs.execute("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --status --format=%s")
	currentStatus = trim(currentStatus)
	if (currentStatus == "▶️" and toStatus == "pause") or (currentStatus == "⏸" and toStatus == "play") then
		local stdout = hs.execute("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --toggle")
		if (toStatus == "play") then notify(stdout) end
	end
end
function youtubeSpotify (appName, eventType)
	if not(appName == "YouTube") then return end


	if (eventType == aw.launched) then
		spotifyTUI("pause")
	elseif (eventType == aw.terminated) then
		spotifyTUI("play")
	end
end
youtubeWatcher = aw.new(youtubeSpotify)
youtubeWatcher:start()

--------------------------------------------------------------------------------
-- SCRIPT EDITOR
wf_script_editor = wf.new("Script Editor")
wf_script_editor:subscribe(wf.windowCreated, function (newWindow)
	if newWindow:title() == "Open" then
		keystroke({"cmd"}, "n")
		runDelayed (0.2, function ()
			keystroke({"cmd"}, "v")
			moveResizeCurWin("centered")
		end)
		runDelayed (0.4, function ()
			keystroke({"cmd"}, "k")
		end)
	end
end)

--------------------------------------------------------------------------------

-- DISCORD
function discordWatcher(appName, eventType)
	if appName ~= "Discord" then return end
	_, discordrpcInstalled = hs.execute('grep "obsidian-discordrpc" "$HOME/Main Vault/.obsidian/community-plugins.json"')

	-- on launch, open OMG Server instead of friends (who needs friends if you have Obsidian?)
	-- and reconnect Obsidian's Discord Rich Presence (Obsidian launch already covered by RP Plugin)
	if eventType == hs.application.watcher.launched then
		hs.urlevent.openURL("discord://discord.com/channels/686053708261228577/700466324840775831")

		if appIsRunning("Obsidian") and discordrpcInstalled then
			runDelayed(3, function()
				if not appIsRunning("Obsidian") or not appIsRunning("Discord") then return end -- app(s) could have been closed in the meantime
				hs.urlevent.openURL("obsidian://advanced-uri?vault=Main%20Vault&commandid=obsidian-discordrpc%253Areconnect-discord")
				hs.application("Discord"):activate()
			end)
		end
	end

	-- when Discord is focused, enclose URL in clipboard with <>
	-- when Discord is unfocused, removes <> from URL in clipboard
	local clipb = hs.pasteboard.getContents()
	if not (clipb) then return end

	if eventType == aw.activated then
		local hasURL = clipb:match('^https?:%S+$')
		local hasObsidianURL = clipb:match('^obsidian:%S+$')
		if hasURL or hasObsidianURL then
			hs.pasteboard.setContents("<"..clipb..">")
		end
	elseif eventType == hs.application.watcher.deactivated then
		local hasEnclosedURL = clipb:match('^<https?:%S+>$')
		local hasEnclosedObsidianURL = clipb:match('^<obsidian:%S+>$')
		if hasEnclosedURL or hasEnclosedObsidianURL then
			clipb = clipb:sub(2, -2) -- remove first & last character
			hs.pasteboard.setContents(clipb)
		end
	end
end
discordAppWatcher = aw.new(discordWatcher)
discordAppWatcher:start()

