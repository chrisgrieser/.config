require("lua.utils")
require("lua.window-management")
require("lua.system-and-cron")
--------------------------------------------------------------------------------
-- HELPERS

-- unhide all apps
local function unHideAll()
	local wins = hs.window.allWindows()
	for _, win in pairs(wins) do
		local app = win:application()
		if app and app:isHidden() then app:unhide() end
	end
end

-- hide windows of other apps, except twitter
---@param win hs.window the window of the app not to hide
local function hideOthers(win)
	local wins = win:otherWindowsSameScreen()
	local winName = win:application():name()
	for _, w in pairs(wins) do
		local app = w:application()
		if app and app:name() ~= "Twitter" and app:name() ~= winName then app:hide() end
	end
end

local function bringAllToFront()
	App.frontmostApplication():selectMenuItem { "Window", "Bring All to Front" }
end

--------------------------------------------------------------------------------

-- AUTOMATIONS FOR MULTIPLE APPS
TransBgAppWatcher = Aw.new(function(appName, eventType, appObject)
	local appsWithTransparency = { "neovide", "Neovide", "Obsidian", "alacritty", "Alacritty" }
	if not TableContains(appsWithTransparency, appName) then return end
	if IsProjector() then return end

	if eventType == Aw.activated or eventType == Aw.launched then
		-- some apps like neovide do not set a "launched" signal, so the delayed
		-- hiding is used for it activation as well
		RunWithDelays({ 0, 0.1, 0.2, 0.3 }, function()
			local win = appObject:mainWindow()
			if not win then return end
			if CheckSize(win, PseudoMaximized) or CheckSize(win, Maximized) then hideOthers(win) end
		end)
	elseif eventType == Aw.terminated then
		unHideAll()
	end
end):start()

-- when currently auto-tiled, hide the app on deactivation to it does not cover sketchybar
AutoTileAppWatcher = Aw.new(function(appName, eventType, appObj)
	local autoTileApps = { "Finder", "Brave Browser" }
	if eventType == Aw.deactivated and TableContains(autoTileApps, appName) then
		if #appObj:allWindows() > 1 then appObj:hide() end
	end
end):start()

-- prevent maximized window from covering sketchybar if they are unfocused
-- pseudomaximized windows always get twitter to the side
Wf_maxWindows = Wf.new(true):subscribe(Wf.windowUnfocused, function(win)
	if IsProjector() then return end
	if CheckSize(win, Maximized) then win:application():hide() end
end)

---play/pause spotify with spotifyTUI
---@param toStatus string pause|play
local function spotifyTUI(toStatus)
	local currentStatus = hs.execute(
		"export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --status --format=%s"
	)
	currentStatus = Trim(currentStatus) ---@diagnostic disable-line: param-type-mismatch
	if
		(currentStatus == "▶️" and toStatus == "pause")
		or (currentStatus == "⏸" and toStatus == "play")
	then
		local stdout = hs.execute(
			"export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --toggle"
		)
		if toStatus == "play" then Notify(stdout) end ---@diagnostic disable-line: param-type-mismatch
	end
end

-- auto-pause Spotify on launch of apps w/ sound
-- auto-resume Spotify on quit of apps w/ sound
SpotifyAppWatcher = Aw.new(function(appName, eventType)
	if IsProjector() then return end -- never start music when on projector
	local appsWithSound = { "YouTube", "zoom.us", "FaceTime", "Twitch", "Netflix", "CrunchyRoll" }
	if TableContains(appsWithSound, appName) then
		if eventType == Aw.launched then
			spotifyTUI("pause")
		elseif eventType == Aw.terminated then
			spotifyTUI("play")
		end
	end
end):start()

--------------------------------------------------------------------------------

-- PIXELMATOR: open maximized
PixelmatorWatcher = Aw.new(function(appName, eventType, appObj)
	if appName == "Pixelmator" and eventType == Aw.launched then
		RunWithDelays(0.3, function() MoveResize(appObj, Maximized) end)
	end
end):start()

--------------------------------------------------------------------------------

-- BRAVE BROWSER
-- split when second window is opened
-- change sizing back, when back to one window
Wf_browser = Wf.new("Brave Browser")
	:setOverrideFilter({
		rejectTitles = { " %(Private%)$", "^Picture in Picture$", "^Task Manager$" },
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(Wf.windowCreated, function()
		AutoTile(Wf_browser)

		-- HACK to fix autofocus-bug in Brave
		RunWithDelays(0.5, function()
			if #Wf_browser:getWindows() ~= 1 then return end
			local prevCur = hs.mouse.getRelativePosition()
			local screen = hs.mouse.getCurrentScreen()
			hs.eventtap.leftClick { x = 1000, y = 500 }
			hs.mouse.setRelativePosition(prevCur, screen)
		end)
	end)
	:subscribe(Wf.windowDestroyed, function() AutoTile(Wf_browser) end)
	:subscribe(Wf.windowFocused, bringAllToFront)

-- Automatically hide Browser has when no window
-- requires wider window-filter to not hide PiP windows etc
Wf_browser_all = Wf.new("Brave Browser")
	:setOverrideFilter({ allowRoles = "AXStandardWindow" })
	:subscribe(Wf.windowDestroyed, function()
		if #Wf_browser_all:getWindows() == 0 then App("Brave Browser"):hide() end
	end)

--------------------------------------------------------------------------------

-- IINA: Full Screen when on projector
IinaAppLauncher = Aw.new(function(appName, eventType, appObject)
	if eventType == Aw.launched and appName == "IINA" and IsProjector() then
		-- going full screen needs a small delay
		RunWithDelays(
			{ 0.05, 0.2 },
			function() appObject:selectMenuItem { "Video", "Enter Full Screen" } end
		)
	end
end):start()

--------------------------------------------------------------------------------

-- NEOVIM / NEOVIDE

-- Add dots when copypasting to from Obsidian devtools
-- not using window focused, since not reliable
local function clipboardFix()
	if not App("neovide"):mainWindow():title():find("%.css$") then return end

	local clipb = hs.pasteboard.getContents()
	if not clipb then return end

	local hasSelectorAndClass = clipb:find(".%-.") and not (clipb:find("[\n.=]"))
	if not hasSelectorAndClass then return end

	clipb = clipb:gsub("^", "."):gsub(" ", ".")
	hs.pasteboard.setContents(clipb)
end

NeovideWatcher = Aw.new(function(appName, eventType, appObj)
	if not appName or appName:lower() ~= "neovide" then return end

	local neovideWin = appObj:mainWindow()
	if eventType == Aw.activated then
		clipboardFix()
		-- maximize app, INFO cannot use aw.launched, since that signal isn't sent
		-- by neovide
		RunWithDelays({ 0.2, 0.4, 0.6, 0.8, 1 }, function()
			if not neovideWin then return end
			if CheckSize(neovideWin, LeftHalf) or CheckSize(neovideWin, RightHalf) then return end
			local size = IsProjector() and Maximized or PseudoMaximized
			MoveResize(neovideWin, size)
		end)

	-- HACK bugfix for: https://github.com/neovide/neovide/issues/1595
	elseif eventType == Aw.terminated then
		RunWithDelays(5, function() hs.execute("pgrep neovide || killall nvim") end)
	end
end):start()

--------------------------------------------------------------------------------

-- ALACRITTY
-- pseudomaximized window
Wf_alacritty = Wf.new({ "alacritty", "Alacritty" })
	:setOverrideFilter({ rejectTitles = { "btop" } })
	:subscribe(Wf.windowCreated, function(newWin)
		if IsProjector() then return end -- has it's own layouting already
		MoveResize(newWin, PseudoMaximized)
	end)

-- Man leader hotkey (for Karabiner)
-- work around necessary, cause alacritty creates multiple instances, i.e.
-- multiple applications all with the name "alacritty", preventing conventional
-- methods for focussing a window via AppleScript or `open`
UriScheme("focus-help", function()
	local win = hs.window.find("man:")
	if win then
		win:focus()
	else
		Notify("None open.")
	end
end)

-- btop leader hotkey (for Karabiner and Alfred)
-- work around necessary, cause alacritty creates multiple instances, i.e.
-- multiple applications all with the name "alacritty", preventing conventional
-- methods for focussing a window via AppleScript or `open`
UriScheme("focus-btop", function()
	local win = hs.window.find("^btop$")
	if win then
		win:focus()
		return
	end
	-- 1. using hs.execute does note make that command block hammerspoon
	-- 2. starting with smaller font be able to read all processes
	local success = os.execute([[
			export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
			if ! command -v btop &>/dev/null; then exit 1 ; fi
			nohup alacritty --option="font.size=20" --option="colors.primary.background='#000000'" --title="btop" --command btop &
		]])
	if success then
		RunWithDelays({ 0.2, 0.3, 0.4 }, function()
			local btopWin = hs.window.find("^btop$")
			MoveResize(btopWin, Maximized)
		end)
	else
		Notify("⚠️ btop not installed")
	end
end)

--------------------------------------------------------------------------------

-- QuickLook: bigger window
Wf_quicklook = Wf
	.new(true) -- BUG for some reason, restricting this to "Finder" does not work
	:setOverrideFilter({ allowRoles = "Quick Look" })
	:subscribe(Wf.windowCreated, function(newWin)
		local _, sel = Applescript([[
			tell application "Finder" to return POSIX path of (selection as alias)
		]])
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
		rejectTitles = { "^Quick Look$", "^Move$", "^Bin$", "^Copy$", "^Finder Settings$", " Info$", "^$" }, -- "^$" excludes the Desktop, which has no window title
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(Wf.windowCreated, function() AutoTile(Wf_finder) end)
	:subscribe(Wf.windowDestroyed, function() AutoTile(Wf_finder) end)

FinderAppWatcher = Aw.new(function(appName, eventType, finderAppObj)
	if not (appName == "Finder") then return end

	if eventType == Aw.activated then
		AutoTile("Finder") -- also triggered via app-watcher, since windows created in the bg do not always trigger window filters
		bringAllToFront()
		finderAppObj:selectMenuItem { "View", "Hide Sidebar" }

		-- INFO delay shouldn't be lower than 2-3s, otherwise some scripts cannot
		-- properly utilize Finder
		RunWithDelays({ 2.5, 5, 10 }, function()
			if finderAppObj and #finderAppObj:allWindows() == 0 then finderAppObj:kill() end
		end)
	end
end):start()

--------------------------------------------------------------------------------

-- ZOOM
-- close first window, when second is open
-- don't leave browser tab behind when opening zoom
Wf_zoom = Wf.new("zoom.us"):subscribe(Wf.windowCreated, function()
	QuitApp("BusyCal") -- mostly only used to open a Zoom link
	Applescript([[
			tell application "Brave Browser"
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

	RunWithDelays(1, function()
		if Wf_zoom:getWindows() > 1 then App("zoom.us"):findWindow("^Zoom$"):close() end
	end)
end)

--------------------------------------------------------------------------------

-- HIGHLIGHTS
-- - Sync Dark & Light Mode
-- - Start with Highlight as Selection
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

-- DRAFTS
-- - Hide Toolbar
-- - set workspace
-- - update counter in sketchybar
DraftsWatcher = Aw.new(function(appName, eventType, appObject)
	if not (appName == "Drafts") then return end

	-- update counter in sketchybar
	RunWithDelays({ 0.1, 1 }, function() hs.execute("sketchybar --trigger drafts-counter-update") end)

	if eventType == Aw.launching or eventType == Aw.activated then
		local workspace = IsAtOffice() and "Office" or "Home"
		RunWithDelays({ 0.2 }, function()
			local name = appObject:focusedWindow():title()
			local isTaskList = name:find("Supermarkt$") or name:find("Drogerie$")
			if not isTaskList then appObject:selectMenuItem { "Workspaces", workspace } end
			appObject:selectMenuItem { "View", "Hide Toolbar" }
		end)
	end
end):start()

--------------------------------------------------------------------------------
-- SCRIPT EDITOR
-- - auto-paste and lint content
-- - skip new file creaton dialog
Wf_script_editor = Wf
	.new("Script Editor")
	:subscribe(Wf.windowCreated, function(newWin)
		if newWin:title() == "Open" then
			Keystroke({ "cmd" }, "n")
			RunWithDelays(0.2, function()
				Keystroke({ "cmd" }, "v")
				local win = App("Script Editor"):mainWindow() -- cannot use newWin, since it's the open dialog
				MoveResize(win, Centered)
			end)
			RunWithDelays(0.4, function() Keystroke({ "cmd" }, "k") end)
		end
	end)
	-- fix line breaks, e.g. for copypasting into neovide
	:subscribe(Wf.windowUnfocused, function()
		local clipb = hs.pasteboard.getContents()
		if not clipb then return end
		clipb = clipb:gsub("\r", "\n")
		hs.pasteboard.setContents(clipb)
	end)

--------------------------------------------------------------------------------

-- DISCORD
DiscordAppWatcher = Aw.new(function(appName, eventType)
	if appName ~= "Discord" then return end

	-- on launch, open OMG Server instead of friends (who needs friends if you have Obsidian?)
	if eventType == Aw.launched then
		OpenLinkInBackground("discord://discord.com/channels/686053708261228577/700466324840775831")
	end

	-- when focused, enclose URL in clipboard with <>
	-- when unfocused, removes <> from URL in clipboard
	local clipb = hs.pasteboard.getContents()
	if not clipb then return end

	if eventType == Aw.activated then
		local hasURL = clipb:match("^https?:%S+$")
		local hasObsidianURL = clipb:match("^obsidian:%S+$")
		local isTweet = clipb:match("^https?://twitter%.com") -- for tweets, the previews are actually useful
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
