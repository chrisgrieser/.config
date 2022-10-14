require("lua.utils")
require("lua.window-management")
require("lua.system-and-cron")

--------------------------------------------------------------------------------
-- TRANSPARENT background for Obsidian & Alacritty & Neovim

function hideAllExcept(appNotToHide)
	local mainScreen = hs.screen.mainScreen()
	local wins = hs.window.orderedWindows() -- `orderedWindows()` ignores headless apps like Twitterrific
	for i = 1, #wins do
		local app = wins[i]:application()
		if not(app) then break end

		local winScreen = wins[i]:screen()

		local isPip = false
		if app:name() == "Brave Browser" or app:name() == "YouTube" then -- if Browser has PiP window, do not hide it
			local browserWins = app:allWindows()
			for j = 1, #browserWins do
				if browserWins[j]:title() == "Picture in Picture" then isPip = true end
			end
		end

		if not(app:name() == appNotToHide) and not(isPip) and winScreen == mainScreen then -- main screen as condition for two-screen setups
			app:hide()
		end
	end
end

function unHideAll()
	local wins = hs.window.allWindows() -- using `allWindows`, since `orderedWindows` only lists visible windows
	for i = 1, #wins do
		local app = wins[i]:application()
		if not(app) then break end
		if app:isHidden() then app:unhide() end
	end
end

function transBackgroundApp (appName, eventType, appObject)
	if not(appName == "neovide" or appName == "Neovide" or appName == "Obsidian" or appName == "alacritty" or appName == "Alacritty") then return end

	local win = appObject:mainWindow()
	if (eventType == aw.activated or eventType == aw.launching) and (isPseudoMaximized(win) or isMaximized(win)) then
		hideAllExcept(appName)
	elseif eventType == aw.terminated then
		unHideAll()
	end
end
transBgAppWatcher = aw.new(transBackgroundApp)
transBgAppWatcher:start()

--------------------------------------------------------------------------------

-- OBSIDIAN
-- Sync on Vault close
function obsidianSync (appName, eventType)
	if appName == "Obsidian" and eventType == aw.launched then
		gitVaultSync()
	end
end
obsidianWatcher = aw.new(obsidianSync)
obsidianWatcher:start()

--------------------------------------------------------------------------------

-- BRAVE BROWSER
-- split when second window is opened
-- change sizing back, when back to one window
wf_browser = wf.new("Brave Browser")
	:setOverrideFilter{rejectTitles={" %(Private%)$","^Picture in Picture$", "^Task Manager$"}, allowRoles='AXStandardWindow', hasTitlebar=true}
	:subscribe(wf.windowCreated, function ()
		if #wf_browser:getWindows() == 1 then
			if isAtOffice() or isProjector() then
				moveResizeCurWin("maximized")
			else
				moveResizeCurWin("pseudo-maximized")
			end
		elseif #wf_browser:getWindows() == 2 then
			local win1 = wf_browser:getWindows()[1]
			local win2 = wf_browser:getWindows()[2]
			moveResize(win1, hs.layout.left50)
			moveResize(win2, hs.layout.right50)
		end
	end)
	:subscribe(wf.windowDestroyed, function ()
		if #wf_browser:getWindows() == 1 then
			local win = wf_browser:getWindows()[1]
			moveResize(win, baseLayout)
		end
	end)
	:subscribe(wf.windowTitleChanged, function (win)
		local hasSound = win:title():find("Audio playing")
		-- not working properly when the tab stays the same, but at least works
		-- with tab change. Since background tabs do have "audio playing" as
		-- title, there is no good trigger for starting again.
		if hasSound then spotifyTUI("pause") end
	end)

-- Automatically hide Browser when no window
wf_browser_all = wf.new("Brave Browser")
	:setOverrideFilter{allowRoles='AXStandardWindow'}
	:subscribe(wf.windowDestroyed, function ()
		if #wf_browser_all:getWindows() == 0 then
			hs.application("Brave Browser"):hide()
		end
	end)

--------------------------------------------------------------------------------

-- MIMESTREAM
-- split when second window is opened
-- change sizing back, when back to one window
wf_mimestream = wf.new("Mimestream")
	:setOverrideFilter{allowRoles='AXStandardWindow', rejectTitles={"General", "Accounts", "Sidebar & List", "Viewing", "Composing", "Templates", "Signatures", "Labs", "Updating Mimestream"}}
	:subscribe(wf.windowCreated, function ()
		if #wf_mimestream:getWindows() == 2 then
			local win1 = wf_mimestream:getWindows()[1]
			local win2 = wf_mimestream:getWindows()[2]
			moveResize(win1, hs.layout.left50)
			moveResize(win2, hs.layout.right50)
		end
	end)
	:subscribe(wf.windowDestroyed, function ()
		if #wf_mimestream:getWindows() == 1 then
			local win = wf_mimestream:getWindows()[1]
			moveResize(win, baseLayout)
		end
	end)
	:subscribe(wf.windowFocused, function ()
		hs.application("Mimestream"):selectMenuItem({"Window", "Bring All to Front"})
	end)

--------------------------------------------------------------------------------

-- keep TWITTERRIFIC visible, when active window is pseudomaximized
function twitterrificNextToPseudoMax(_, eventType)
	if appIsRunning("Twitterrific") and (eventType == aw.activated or eventType == aw.launching) then
		local currentWin = hs.window.focusedWindow()
		if isPseudoMaximized(currentWin) then
			hs.application("Twitterrific"):mainWindow():raise()
		end
	end
end
anyAppActivationWatcher = aw.new(twitterrificNextToPseudoMax)
anyAppActivationWatcher:start()

--------------------------------------------------------------------------------

-- NEOVIM
-- pseudomaximized window
wf_neovim = wf.new("neovide")
	:subscribe(wf.windowCreated, function ()
		if isAtOffice() or isProjector() then
			moveResizeCurWin("maximized")
		else
			moveResizeCurWin("pseudo-maximized")
		end
	end)
	-- bugfix for: https://github.com/neovide/neovide/issues/1595
	:subscribe(wf.windowDestroyed, function ()
		if #wf_neovim:getWindows() == 0 then
			runDelayed(3, function ()
				hs.execute("pgrep neovide || pkill nvim")
			end)
		end
	end)

--------------------------------------------------------------------------------

-- ALACRITTY
-- pseudomaximized window
wf_alacritty = wf.new("alacritty")
	:setOverrideFilter{rejectTitles={"^cheatsheet: "}}
	:subscribe(wf.windowCreated, function ()
		if isAtOffice() or isProjector() then
			moveResizeCurWin("maximized")
		else
			moveResizeCurWin("pseudo-maximized")
		end
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
function finderWatcher(appName, eventType, appObject)
	if not(appName == "Finder") then return end

	if eventType == aw.activated then
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
	elseif eventType == aw.launched then
		-- quit finder if it was started as a helper, but has no window
		runDelayed(1, function ()
			if not(appObject) then return end
			if not(appObject:mainWindow()) then
				appObject:kill()
			end
		end)
	end
end
finderAppWatcher = aw.new(finderWatcher)
finderAppWatcher:start()

-- quit when last window closed
wf_finder = wf.new("Finder")
wf_finder:subscribe(wf.windowDestroyed, function ()
	if #wf_finder:getWindows() == 0 then
		hs.application("Finder"):kill()
	end
end)

--------------------------------------------------------------------------------

-- MARTA
-- - (pseudo)maximize
-- - close other tabs when reopening
-- - quit Marta when no window remaining
wf_marta = wf.new("Marta")
	:setOverrideFilter{allowRoles='AXStandardWindow', rejectTitles="^Preferences$"}
	:subscribe(wf.windowCreated, function ()
		runDelayed(0.1, function () -- close other tabs, needed because: https://github.com/marta-file-manager/marta-issues/issues/896
			keystroke({"shift"}, "w", 1, hs.application("Marta"))
		end)
		if isAtOffice() or isProjector() then
			moveResizeCurWin("maximized")
		else
			moveResizeCurWin("pseudo-maximized")
		end
	end)
	:subscribe(wf.windowDestroyed, function ()
		if #wf_marta:getWindows() == 0 then
			hs.application("Marta"):kill()
		end
	end)

--------------------------------------------------------------------------------

-- ZOOM
-- close first window, when second is open
-- don't leave tab behind when opening zoom
wf_zoom = wf.new("zoom.us")
	:subscribe(wf.windowCreated, function ()
		local numberOfZoomWindows = #wf_zoom:getWindows();
		if numberOfZoomWindows == 2 then
			runDelayed (1.3, function()
				hs.application("zoom.us"):findWindow("^Zoom$"):close()
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
draftsWatcher = aw.new(draftsLaunchWake)
draftsWatcher:start()

--------------------------------------------------------------------------------

-- MACPASS: properly show when activated
function macPassActivate(appName, eventType, appObject)
	if not(appName == "MacPass") or not(eventType == aw.launched) then return end
	runDelayed(0.3, function () appObject:activate() end)
end
macPassWatcher = aw.new(macPassActivate)
macPassWatcher:start()

--------------------------------------------------------------------------------

-- SPOTIFY
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

function SpotifyToggler (appName, eventType)
	if appName == "YouTube" or appName == "zoom.us" or appName == "FaceTime" then
		if eventType == aw.launched then
			spotifyTUI("pause")
		elseif eventType == aw.terminated and not(isProjector()) then
			spotifyTUI("play")
		end
	end
end
spotifyAppWatcher = aw.new(SpotifyToggler)
if not(isAtOffice()) then spotifyAppWatcher:start() end

--------------------------------------------------------------------------------
-- SCRIPT EDITOR
wf_script_editor = wf.new("Script Editor")
	:subscribe(wf.windowCreated, function (newWindow)
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

	-- on launch, open OMG Server instead of friends (who needs friends if you have Obsidian?)
	if eventType == hs.application.watcher.launched then
		hs.urlevent.openURL("discord://discord.com/channels/686053708261228577/700466324840775831")
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
	elseif eventType == aw.deactivated then
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

--------------------------------------------------------------------------------

-- SHOTTR: Auto-select Arrow
wf_shottr = wf.new("Shottr")
	:subscribe(wf.windowCreated, function(newWindow)
		if newWindow:title() == "Preferences" then return end

		runDelayed (0.1, function () keystroke({}, "a") end)
	end)

