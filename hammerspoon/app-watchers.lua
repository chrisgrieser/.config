require("utils")
require("window-management")

-- FINDER: when activated
-- - Bring all windows forward
-- - hide sidebar
-- - enlarge window if it's too small
-- - hide Finder when no window
function finderWatcher(appName, eventType, appObject)
	if not(eventType == aw.activated and appName == "Finder") then return end

	appObject:selectMenuItem({"Window", "Bring All to Front"})
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

	runDelayed(0.1, function ()
		local hasNoWindows = #(appObject:allWindows()) == 0
		if hasNoWindows then appObject:hide() end
	end)
end
finderAppWatcher = aw.new(finderWatcher)
finderAppWatcher:start()

-- ZOOM: don't leave behind tab when opening URL
function zoomWatcher(appName, eventType)
	if not(eventType == aw.launched and appName == "zoom.us") then return end
	runDelayed(3, function ()
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
zoomAppWatcher = aw.new(zoomWatcher)
zoomAppWatcher:start()

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
	if isAtOffice() then
		runDelayed(0.2, function () moveResizeCurWin("maximized") end)
	else
		runDelayed(0.2, function () moveResizeCurWin("pseudo-maximized") end)
	end
end
highlightsAppWatcher = aw.new(highlightsWatcher)
highlightsAppWatcher:start()

-- DRAFTS: Hide Toolbar
function draftsLaunchWake(appName, eventType, appObject)
	if not(appName == "Drafts") then return end

	if (eventType == aw.launched) then
		runDelayed(1, function ()
			appObject:selectMenuItem({"View", "Hide Toolbar"})
		end)
	elseif (eventType == aw.activated) then
		appObject:selectMenuItem({"View", "Hide Toolbar"})
	end
end
draftsWatcher3 = aw.new(draftsLaunchWake)
draftsWatcher3:start()


-- MACPASS: properly show when activated
function macPassActivate(appName, eventType, appObject)
	if not(appName == "MacPass") or not(eventType == aw.launched) then return end

	runDelayed(0.3, function ()
		appObject:activate()
	end)
end
macPassWatcher = aw.new(macPassActivate)
macPassWatcher:start()

-- YOUTUBE + SPOTIFY
-- Pause Spotify on launch
-- Resume Spotify on quit
function spotifyTUI (toStatus)
	local currentStatus = hs.execute("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --status --format=%s")
	currentStatus = trim(currentStatus)
	if (toStatus == "toggle") or (currentStatus == "▶️" and toStatus == "pause") or (currentStatus == "⏸" and toStatus == "play") then
		local stdout = hs.execute("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --toggle")
		if (toStatus == "play") then notify(stdout) end
	end
end

function youtubeSpotify (appName, eventType)
	if not(appName == "YouTube") then return end
	if isProjector() or isAtOffice() then return end

	if (eventType == aw.launched) then
		spotifyTUI("pause")
	elseif (eventType == aw.terminated) then
		spotifyTUI("play")
	end
end
youtubeWatcher = aw.new(youtubeSpotify)
youtubeWatcher:start()

-- SCRIPT EDITOR
function scriptEditorLaunch (appName, eventType)
	if not(appName == "Script Editor" and eventType == aw.launched) then return end
	runDelayed (0.3, function () keystroke({"cmd"}, "n") end)
	runDelayed (0.6, function ()
		keystroke({"cmd"}, "v")
		moveResizeCurWin("centered")
	end)
	runDelayed (0.9, function () keystroke({"cmd"}, "k") end)
end
scriptEditorWatcher = aw.new(scriptEditorLaunch)
scriptEditorWatcher:start()

