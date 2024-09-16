local M = {} -- persist from garbage collector

local env = require("modules.environment-vars")
local u = require("modules.utils")
local wu = require("modules.window-utils")
local aw = hs.application.watcher
local wf = hs.window.filter

--------------------------------------------------------------------------------
-- FINDER

M.wf_finder = wf
	.new("Finder")
	:setOverrideFilter({
		-- Info windows only *end* with "Info"
		rejectTitles = { "^Move$", "^Copy$", "^Delete$", "^Finder Settings$", " Info$" },
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(wf.windowCreated, function(win)
		local winOnMainScreen = win:screen():id() == hs.screen.mainScreen():id()
		local finder = u.app("Finder")
		if env.isProjector() and winOnMainScreen then
			wu.moveResize(win, wu.maximized)
		elseif win:isMaximizable() and win:isStandard() and finder and finder:isFrontmost() then
			u.runWithDelays(0.05, function() wu.autoTile(M.wf_finder) end)
		end
	end)
	-- no condition checks needed, since destroyed windows do not have properties
	:subscribe(
		wf.windowDestroyed,
		function() wu.autoTile(M.wf_finder) end
	)

-- also trigger autoTile via app-watcher, since windows created in the
-- background do not always trigger window filters
M.aw_finder = aw.new(function(appName, eventType, finder)
	if eventType == aw.activated and appName == "Finder" then
		finder:selectMenuItem { "View", "Hide Sidebar" }
		if not env.isProjector() then finder:selectMenuItem { "View", "as List" } end
		wu.autoTile("Finder")
	end
end):start()

--------------------------------------------------------------------------------
-- ZOOM

M.wf_zoom = wf.new("zoom.us"):subscribe(wf.windowCreated, function(newWin)
	u.quitApps("BusyCal") -- only used to open a Zoom link
	u.closeTabsContaining("zoom.us") -- remove leftover tabs

	-- close 2nd zoom window when joining a meeting
	if newWin:title() == "Zoom Meeting" then
		u.runWithDelays(1, function()
			local zoom = newWin:application()
			if not zoom or zoom:findWindow("Update") then return end
			local mainWin = zoom:findWindow("Zoom Workplace")
			if mainWin then mainWin:close() end
		end)
	end
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
M.wf_pdfReader = wf.new({ "Preview", "Highlights" }):subscribe(
	wf.windowCreated,
	function(newWin) wu.moveResize(newWin, wu.pseudoMax) end
)

------------------------------------------------------------------------------
-- TRANSMISSION / MASTODON

-- Fallthrough: prevent unintended focusing after qutting another app or closing
-- last window
M.aw_fallthrough = aw.new(function(appName, event)
	if appName == "Reminders" then return end -- Reminders often opening in the background
	if event ~= aw.terminated then return end

	-- CONFIG
	local fallThroughApps = { "Transmission", "Mona" }
	u.runWithDelays({ 0.1, 0.2 }, function()
		if not u.isFront(fallThroughApps) then return end
		local visibleWins = hs.window:orderedWindows()
		local nextWin
		for _, win in pairs(visibleWins) do
			if not win:application() then return end
			local name = win:application():name() ---@diagnostic disable-line: undefined-field
			if not (hs.fnutils.contains(fallThroughApps, name)) then
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
			hs.osascript.applescript('tell application "Script Editor" to make new document')

		-- auto-paste, format, and resize window
		elseif newWin:title() == "Untitled" then
			wu.moveResize(newWin, wu.middleHalf)
			local clipb = hs.pasteboard.getContents()
			hs.osascript.javascript(([[
				Application("Script Editor").documents()[0].text = `%s`;
				Application("Script Editor").documents()[0].checkSyntax();
			]]):format(clipb))

		-- just resize window if it's an AppleScript Dictionary
		elseif newWin:title():find("%.sdef$") then
			wu.moveResize(newWin, wu.middleHalf)
		end
	end)
	-- fix copypasting line breaks into other apps
	:subscribe(wf.windowUnfocused, function()
		local clipb = hs.pasteboard.getContents()
		if clipb then
			clipb = clipb:gsub("\r", " \n")
			hs.pasteboard.setContents(clipb)
		end
	end)

--------------------------------------------------------------------------------
-- MIMESTREAM

-- 1st window = mail-list window => pseudo-maximized for more space
-- 2nd window = message-composing window => centered for narrower line length
M.wf_mimestream = wf.new("Mimestream")
	:setOverrideFilter({ rejectTitles = { "^Software Update$" } })
	:subscribe(wf.windowCreated, function(newWin)
		local mimestream = u.app("Mimestream")
		if not mimestream then return end
		local winCount = #mimestream:allWindows()
		local newSize = winCount > 1 and wu.narrow or wu.pseudoMax
		wu.moveResize(newWin, newSize)
	end)

--------------------------------------------------------------------------------
-- DISCORD

M.aw_discord = aw.new(function(appName, eventType)
	if appName ~= "Discord" then return end

	-- on launch, open a specific channel rather than the friends view
	if eventType == aw.launched or eventType == aw.launching then
		local channelUri = "discord://discord.com/channels/1231936600204902481/1231936600674668604"
		u.openInBackground(channelUri)
		return
	end

	-- when focused, enclose URL in clipboard with <>
	-- when unfocused, removes <> from URL in clipboard
	local clipb = hs.pasteboard.getContents()
	if clipb and eventType == aw.activated then
		local hasURL = clipb:find("^https?:%S+$") or clipb:find("^obsidian://%S+$")
		-- for tweets, the previews are actually useful since they show the full content
		local isTweet = clipb:find("^https?://x%.com") or clipb:find("^https?://mastodon%.*")
		if hasURL and not isTweet then hs.pasteboard.setContents("<" .. clipb .. ">") end
	elseif clipb and eventType == aw.deactivated then
		local hasEnclosedURL = clipb:find("^<https?:%S+>$") or clipb:find("^<obsidian:%S+>$")
		if hasEnclosedURL then
			clipb = clipb:sub(2, -2) -- remove first & last character
			hs.pasteboard.setContents(clipb)
		end
	end
end):start()

--------------------------------------------------------------------------------
return M
