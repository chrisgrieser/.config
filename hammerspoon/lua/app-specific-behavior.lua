local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
local aw = hs.application.watcher
local wf = hs.window.filter

--------------------------------------------------------------------------------

---play/pause spotify
---@param toStatus string pause|play
local function spotifyDo(toStatus)
	local status = hs.execute(u.exportPath .. "spt playback --status --format=%s"):gsub("\n$", "") ---@diagnostic disable-line: undefined-field
	if (status == "▶️" and toStatus == "pause") or (status == "⏸" and toStatus == "play") then
		local stdout = hs.execute(u.exportPath .. "spt playback --toggle")
		if toStatus == "play" then u.notify(stdout) end
	end
end

-- auto-pause/resume Spotify on launch/quit of apps with sound
M.aw_spotify = aw.new(function(appName, eventType)
	if
		not u.screenIsUnlocked()
		or env.isAtOffice
		or env.isProjector()
		or not (u.tbl_contains(env.videoAndAudioApps, appName))
	then
		return
	end

	if eventType == aw.launched then
		spotifyDo("pause")
	elseif eventType == aw.terminated then
		spotifyDo("play")
	end
end):start()

--------------------------------------------------------------------------------

-- PIXELMATOR: open maximized
M.aw_pixelmator = aw.new(function(appName, eventType, pixelmator)
	if appName == "Pixelmator" and eventType == aw.launched then
		u.whenAppWinAvailable(appName, function() wu.moveResize(pixelmator, wu.maximized) end)
	end
end):start()

--------------------------------------------------------------------------------
-- OBSIDIAN

---half -> hide right sidebar
---pseudo-maximized -> show right sidebar
---max -> hide right sidebars (assuming split)
---requires: Obsidian Advanced URI plugin with `eval` being enabled
M.wf_obsidanMoved = wf.new("Obsidian"):subscribe(wf.windowMoved, function(obsiWin)
	if #u.app("Obsidian"):allWindows() > 1 then return end -- prevent popout window resizing to affect sidebars

	local relObsiWinWidth = obsiWin:size().w / obsiWin:screen():frame().w
	local modeRight = (relObsiWinWidth > 0.6 and relObsiWinWidth < 0.99) and "expand" or "collapse"
	u.openLinkInBg(
		"obsidian://advanced-uri?eval=this.app.workspace.rightSplit." .. modeRight .. "%28%29"
	)
end)

--------------------------------------------------------------------------------
-- FINDER

M.wf_finder = wf.new("Finder")
	:setOverrideFilter({
		-- Info windows *end* with "Info"
		rejectTitles = { "^Move$", "^Copy$", "^Delete$", "^Finder Settings$", " Info$" },
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(wf.windowCreated, function(win)
		local winOnMainScreen = win:screen():id() == hs.screen.mainScreen():id()
		if env.isProjector() and winOnMainScreen then
			wu.moveResize(win, wu.maximized)
		elseif win:isMaximizable() and win:isStandard() and u.app("Finder"):isFrontmost() then
			u.runWithDelays(0.05, function() wu.autoTile(M.wf_finder) end)
		end
	end)
	:subscribe(wf.windowDestroyed, function()
		-- no conditions, since destroyed windows do not have properties
		wu.autoTile(M.wf_finder)
	end)

-- also triggered via app-watcher, since windows created in the background do
-- not always trigger window filters
M.aw_finder = aw.new(function(appName, eventType, finder)
	if eventType == aw.activated and appName == "Finder" then
		finder:selectMenuItem { "View", "Hide Sidebar" }
		if not env.isProjector() then finder:selectMenuItem { "View", "as List" } end
		wu.autoTile("Finder")
	end
end):start()

--------------------------------------------------------------------------------

-- ZOOM
-- close first window, when second is open
-- don't leave browser tab behind when opening zoom
M.wf_zoom = wf.new("zoom.us"):subscribe(wf.windowCreated, function()
	u.quitApps("BusyCal") -- only used to open a Zoom link
	u.closeTabsContaining("zoom.us") -- remove leftover tabs
	u.runWithDelays(1, function()
		local zoom = u.app("zoom.us")
		if not zoom or zoom:findWindow("Update") then return end
		local secondWin = zoom:findWindow("^Zoom$") or zoom:findWindow("^Login$")
		-- zoom always has an invisible, title-less third window running, thus three
		if not secondWin or #M.wf_zoom:getWindows() < 3 then return end
		secondWin:close()
	end)
end)

--------------------------------------------------------------------------------

-- HIGHLIGHTS / PDF READER
-- - Sync Dark & Light Mode
-- - Start with Highlight Tool enabled
M.aw_highlights = aw.new(function(appName, eventType, highlights)
	if not (eventType == aw.launched and appName == "Highlights") then return end

	-- set appearance according to dark mode
	local targetView = u.isDarkMode() and "Night" or "Default"
	highlights:selectMenuItem { "View", "PDF Appearance", targetView }

	-- pre-select yellow highlight tool & hide toolbar
	highlights:selectMenuItem { "Tools", "Highlight" }
	highlights:selectMenuItem { "Tools", "Color", "Yellow" }
	highlights:selectMenuItem { "View", "Hide Toolbar" }
end):start()

-- open all windows pseudo-maximized
M.wf_pdfReader = wf.new({ "Preview", "Highlights", "PDF Expert" }):subscribe(
	wf.windowCreated,
	function(newWin) wu.moveResize(newWin, wu.pseudoMax) end
)

------------------------------------------------------------------------------

-- FIX window position not being remembered
M.aw_readkit = aw.new(function(appName, event)
	if appName == "ReadKit" and event == aw.activated then
		u.runWithDelays({ 0, 0.2 }, function()
			local win = u.app("ReadKit"):mainWindow()
			if win then wu.moveResize(win, wu.pseudoMax) end
		end)
	end
end):start()

------------------------------------------------------------------------------

-- TRANSMISSION / TWITTER / MASTODON / TOT
-- Fallthrough: prevent unintended focusing after qutting another app or closing
-- last window

M.aw_fallthrough = aw.new(function(appName, event)
	if appName == "Reminders" then return end -- Reminders often opening in the background
	if event ~= aw.terminated then return end

	-- CONFIG
	local fallThroughApps = { "Transmission", env.tickerApp, "Tot" }
	u.runWithDelays({ 0.1, 0.2 }, function()
		if not u.isFront(fallThroughApps) then return end
		local visibleWins = hs.window:orderedWindows()
		local nextWin
		for _, win in pairs(visibleWins) do
			if not win:application() then return end
			local name = win:application():name() ---@diagnostic disable-line: undefined-field
			if not (u.tbl_contains(fallThroughApps, name)) then
				nextWin = win
				break
			end
		end
		if not nextWin or (nextWin:id() == hs.window.frontmostWindow():id()) then return end
		nextWin:focus()
	end)
end):start()

--------------------------------------------------------------------------------
-- SCRIPT EDITOR
M.wf_scripteditor = wf
	.new("Script Editor")
	:subscribe(wf.windowCreated, function(newWin)
		-- skip new file creation dialog
		if newWin:title() == "Open" then
			u.applescript('tell application "Script Editor" to make new document')
		-- auto-paste and lint content; resize window
		elseif newWin:title() == "Untitled" then
			wu.moveResize(newWin, wu.centerHalf)
			local clipb = hs.pasteboard.getContents()
			hs.osascript.javascript(([[
				Application("Script Editor").documents()[0].text = `%s`;
				Application("Script Editor").documents()[0].checkSyntax();
			]]):format(clipb))
		-- just resize window if it's an AppleScript Dictionary
		elseif newWin:title():find("%.sdef$") then
			wu.moveResize(newWin, wu.centerHalf)
		end
	end)
	-- fix copypasting line breaks into other apps
	:subscribe(wf.windowUnfocused, function()
		local clipb = hs.pasteboard.getContents()
		if not clipb then return end
		clipb = clipb:gsub("\r", " \n")
		hs.pasteboard.setContents(clipb)
	end)

--------------------------------------------------------------------------------
-- MIMESTREAM

-- move new window
M.wf_mimestream = wf.new("Mimestream"):subscribe(
	wf.windowCreated,
	function(newWin) wu.moveResize(newWin, wu.pseudoMax) end
)

--------------------------------------------------------------------------------
-- TEXTPAL

-- FIX window opening on System-Start
if u.isSystemStart() then
	local textpal = u.app("TextPal")
	if textpal and textpal:mainWindow() then textpal:mainWindow():close() end
end

--------------------------------------------------------------------------------

-- DISCORD
-- when focused, enclose URL in clipboard with <>
-- when unfocused, removes <> from URL in clipboard
M.aw_discord = aw.new(function(appName, eventType)
	if not (appName == "Discord") then return end

	local clipb = hs.pasteboard.getContents()
	if not clipb then return end

	if eventType == aw.launched or eventType == aw.launching then
		-- #off-topic in OMG Discord-server
		u.openLinkInBg("discord://discord.com/channels/686053708261228577/700466324840775831")
	elseif eventType == aw.activated then
		local hasURL = clipb:find("^https?:%S+$")
		local hasObsidianURL = clipb:find("^obsidian://%S+$")
		local isTweet = clipb:find("^https?://twitter%.com") -- for tweets, the previews are actually useful since they show the full content
		local isToot = clipb:find("^https?://mastodon%.*") -- same for toots
		if (hasURL or hasObsidianURL) and not (isTweet or isToot) then
			hs.pasteboard.setContents("<" .. clipb .. ">")
		end
	elseif eventType == aw.deactivated then
		local hasEnclosedURL = clipb:find("^<https?:%S+>$")
		local hasEnclosedObsidianURL = clipb:find("^<obsidian:%S+>$")
		if hasEnclosedURL or hasEnclosedObsidianURL then
			clipb = clipb:sub(2, -2) -- remove first & last character
			hs.pasteboard.setContents(clipb)
		end
	end
end):start()

--------------------------------------------------------------------------------
return M
