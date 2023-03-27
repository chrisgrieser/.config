require("lua.utils")
require("lua.window-utils")
--------------------------------------------------------------------------------

---play/pause spotify with Spotify
---@param toStatus string pause|play
local function spotifyDo(toStatus)
	-- INFO keeping both versions here due to potential reoccurence of this bug
	-- https://github.com/Rigellute/spotify-tui/issues/1072

	-- SPOTIFY-DESKTOP
	-- if hs.spotify.isPlaying() and toStatus == "pause" then
	-- 	hs.spotify.pause()
	-- elseif toStatus == "play" then
	-- 	hs.spotify.play()
	-- end

	-- SPOTIFY-TUI
	-- stylua: ignore start
	local currentStatus = hs.execute( "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --status --format=%s"):gsub("\n$", "")
	if
		(currentStatus == "▶️" and toStatus == "pause")
		or (currentStatus == "⏸" and toStatus == "play")
	then
		local stdout = hs.execute( "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --toggle")
		if toStatus == "play" then Notify(stdout) end ---@diagnostic disable-line: param-type-mismatch
	end
	-- stylua: ignore end
end

-- auto-pause/resume Spotify on launch/quit of apps with sound
SpotifyAppWatcher = Aw.new(function(appName, eventType)
	local appsWithSound = { "YouTube", "zoom.us", "FaceTime", "Twitch", "Netflix", "CrunchyRoll" }
	if
		not ScreenIsUnlocked()
		or IsAtOffice()
		or IsProjector()
		or not (TableContains(appsWithSound, appName))
	then
		return
	end

	if eventType == Aw.launched then
		spotifyDo("pause")
	elseif eventType == Aw.terminated then
		spotifyDo("play")
	end
end):start()

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- PIXELMATOR: open maximized
PixelmatorWatcher = Aw.new(function(appName, eventType, appObj)
	if appName == "Pixelmator" and eventType == Aw.launched then
		AsSoonAsAppRuns(appObj, function() MoveResize(appObj, Maximized) end)
	end
end):start()

--------------------------------------------------------------------------------

-- BROWSER (Vivaldi)
Wf_browser = Wf.new("Vivaldi")
	:setOverrideFilter({
		rejectTitles = {
			" %(Private%)$",
			"^Picture in Picture$",
			"^Task Manager$",
			"^Developer Tools", -- when inspecting websites
			"^DevTools", -- when inspecting Vivaldi UI, are titled "^$" on creation
			"^$",
		},
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(Wf.windowCreated, function() AutoTile(Wf_browser) end)
	:subscribe(Wf.windowDestroyed, function() AutoTile(Wf_browser) end)
	:subscribe(Wf.windowFocused, BringAllToFront)

-- Automatically hide Browser has when no window
-- requires wider window-filter to not hide PiP windows etc
Wf_browser_all = Wf.new({ "Vivaldi" })
	:setOverrideFilter({ allowRoles = "AXStandardWindow" })
	:subscribe(Wf.windowDestroyed, function()
		local app = App("Vivaldi")
		if app and #(app:allWindows()) == 0 then app:hide() end
	end)

--------------------------------------------------------------------------------

-- IINA: Full Screen when on projector
IinaAppLauncher = Aw.new(function(appName, eventType, appObj)
	if eventType == Aw.launched and appName == "IINA" and IsProjector() then
		AsSoonAsAppRuns(appObj, function() appObj:selectMenuItem { "Video", "Enter Full Screen" } end)
	end
end):start()

--------------------------------------------------------------------------------

-- NEOVIM / NEOVIDE

-- Add dots when copypasting to from dev tools
local function addCssSelectorLeadingDot()
	if
		not AppIsRunning("neovide")
		or not App("neovide"):mainWindow()
		or not App("neovide"):mainWindow():title():find("%.css$")
	then
		return
	end

	local clipb = hs.pasteboard.getContents()
	if not clipb then return end

	local hasSelectorAndClass = clipb:find(".%-.")
		and not (clipb:find("[\n.=]"))
		and not (clipb:find("^%-%-"))
	if not hasSelectorAndClass then return end

	clipb = clipb:gsub("^", "."):gsub(" ", ".")
	hs.pasteboard.setContents(clipb)
end

NeovideWatcher = Aw.new(function(appName, eventType)
	if not appName or appName:lower() ~= "neovide" then return end

	if eventType == Aw.activated then
		addCssSelectorLeadingDot()

	-- HACK bugfix for: https://github.com/neovide/neovide/issues/1595
	elseif eventType == Aw.terminated then
		RunWithDelays(5, function() hs.execute("pgrep neovide || killall nvim") end)
	end
end):start()

-- HACK since neovide does not send a launch signal, triggering window resizing
-- via its URI scheme called on VimEnter
UriScheme("enlarge-neovide-window", function()
	local neovideWin = App("neovide"):mainWindow()
	local size = IsProjector() and Maximized or PseudoMaximized
	MoveResize(neovideWin, size)
end)

--------------------------------------------------------------------------------

-- ALACRITTY / TERMINAL
-- pseudomaximized window
Wf_terminal = Wf.new({ "alacritty", "Alacritty" })
	:setOverrideFilter({ rejectTitles = { "btop" } })
	:subscribe(Wf.windowCreated, function(newWin, appName)
		AsSoonAsAppRuns(appName, function() MoveResize(newWin, PseudoMaximized) end)
	end)

--------------------------------------------------------------------------------

-- QuickLook: bigger window
Wf_quicklook = Wf
	.new(true) -- BUG for some reason, restricting this to "Finder" does not work
	:setOverrideFilter({ allowRoles = "Quick Look" })
	:subscribe(Wf.windowCreated, function(newWin)
		local _, sel =
			Applescript([[tell application "Finder" to return POSIX path of (selection as alias)]])
		-- do not enlage window for images (which are enlarged already with
		-- landscape proportions)
		if
			sel and (sel:find("%.png$") or sel:find("%.jpe?g$") or sel:find("%.gif") or sel:find("%.mp4"))
		then
			return
		end
		RunWithDelays(0.4, function() MoveResize(newWin, Centered) end)
	end)

--------------------------------------------------------------------------------

-- FINDER
Wf_finder = Wf.new("Finder")
	:setOverrideFilter({
		rejectTitles = {
			"^Quick Look$",
			"^Move$",
			"^Copy$",
			"^Bin$",
			"^Delete$",
			"^Finder Settings$",
			" Info$", -- Info window *end* with "Info"
			"^$", -- Desktop, which has no window title
			"^Alfred$", -- Alfred Compatibility Mode
		},
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(Wf.windowCreated, function() AutoTile(Wf_finder) end)
	:subscribe(Wf.windowDestroyed, function() AutoTile(Wf_finder) end)

FinderAppWatcher = Aw.new(function(appName, eventType, finderAppObj)
	if eventType == Aw.activated and appName == "Finder" then
		AutoTile("Finder") -- also triggered via app-watcher, since windows created in the bg do not always trigger window filters
		finderAppObj:selectMenuItem { "View", "Hide Sidebar" }
	end
end):start()

--------------------------------------------------------------------------------

-- ZOOM
-- close first window, when second is open
-- don't leave browser tab behind when opening zoom
Wf_zoom = Wf.new("zoom.us"):subscribe(Wf.windowCreated, function()
	QuitApp("BusyCal") -- mostly only used to open a Zoom link
	Applescript([[
		tell application "Vivaldi"
			set window_list to every window
			repeat with the_window in window_list
				set tab_list to every tab in the_window
				repeat with the_tab in tab_list
					set the_url to the url of the_tab
					if the_url contains ("zoom.us") then close the_tab
				end repeat
			end repeat
		end tell
	]])
	RunWithDelays(0.5, function()
		if AppIsRunning("zoom.us") and #Wf_zoom:getWindows() > 1 then
			App("zoom.us"):findWindow("^Zoom$"):close()
		end
	end)
end)

-- SIDENOTES
-- update counter in sketchybar
SidenotesWatcher = Aw.new(function(appName, event)
	if appName ~= "SideNotes" then return end
	if event == Aw.activated or event == Aw.deactivated then
		hs.execute("sketchybar --trigger update-sidenote-count")
	end
end):start()
-- hide when alt-tab is used
SidenotesWatcher = Aw.new(function(appName, event)
	if appName == "Alt-Tab" and event == Aw.activated then App("SideNotes"):hide() end
end):start()

--------------------------------------------------------------------------------

-- HIGHLIGHTS
-- - Sync Dark & Light Mode
-- - Start with Highlight Tool enabled
HighlightsAppWatcher = Aw.new(function(appName, eventType, appObject)
	if not (eventType == Aw.launched and appName == "Highlights") then return end

	local targetView = "Default"
	if IsDarkMode() then targetView = "Night" end
	appObject:selectMenuItem { "View", "PDF Appearance", targetView }

	-- pre-select yellow highlight tool & hide toolbar
	appObject:selectMenuItem { "Tools", "Highlight" }
	appObject:selectMenuItem { "Tools", "Color", "Yellow" }
	appObject:selectMenuItem { "View", "Hide Toolbar" }

	MoveResize(appObject:mainWindow(), PseudoMaximized)
end):start()

--------------------------------------------------------------------------------
-- SCRIPT EDITOR
Wf_script_editor = Wf
	.new("Script Editor")
	:subscribe(Wf.windowCreated, function(newWin)
		-- skip new file creation dialogue
		if newWin:title() == "Open" then
			Keystroke({ "cmd" }, "n")
		-- auto-paste and lint content; resize window
		elseif newWin:title() == "Untitled" then
			Keystroke({ "cmd" }, "v")
			MoveResize(newWin, Centered)
			RunWithDelays(0.2, function() Keystroke({ "cmd" }, "k") end)
		-- resize window
		elseif newWin:title():find("%.sdef$") then
			MoveResize(newWin, Centered)
		end
	end)
	-- fix line breaks for copypasting into other apps
	:subscribe(Wf.windowUnfocused, function()
		local clipb = hs.pasteboard.getContents()
		if not clipb then return end
		clipb = clipb:gsub("\r", "\n")
		hs.pasteboard.setContents(clipb)
	end)

--------------------------------------------------------------------------------

-- DISCORD
DiscordAppWatcher = Aw.new(function(appName, eventType, appObj)
	if not (appName == "Discord") then return end

	-- on launch, open OMG Server instead of friends (who needs friends if you have Obsidian?)
	if eventType == Aw.launched then
		AsSoonAsAppRuns(
			appObj,
			function()
				OpenLinkInBackground("discord://discord.com/channels/686053708261228577/700466324840775831")
			end
		)
	end

	-- when focused, enclose URL in clipboard with <>
	-- when unfocused, removes <> from URL in clipboard
	local clipb = hs.pasteboard.getContents()
	if not clipb then return end

	if eventType == Aw.activated then
		local hasURL = clipb:match("^https?:%S+$")
		local hasObsidianURL = clipb:match("^obsidian:%S+$")
		local isTweet = clipb:match("^https?://twitter%.com") -- for tweets, the previews are actually useful since they show the full content
		if (hasURL or hasObsidianURL) and not isTweet then
			hs.pasteboard.setContents("<" .. clipb .. ">")
		end
	elseif eventType == Aw.deactivated then
		local hasEnclosedURL = clipb:match("^<https?:%S+>$")
		local hasEnclosedObsidianURL = clipb:match("^<obsidian:%S+>$")
		if hasEnclosedURL or hasEnclosedObsidianURL then
			clipb = clipb:sub(2, -2) -- remove first & last character
			hs.pasteboard.setContents(clipb)
		end
	end
end):start()
