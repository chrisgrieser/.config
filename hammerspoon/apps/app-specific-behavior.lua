local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------
-- FINDER

M.aw_finder = aw.new(function(appName, event, finder)
	if event == aw.activated and appName == "Finder" then
		finder:selectMenuItem { "View", "Hide Sidebar" }
		if not env.isProjector() then finder:selectMenuItem { "View", "As List" } end
	end
end):start()

--------------------------------------------------------------------------------
-- ZOOM

M.wf_zoom = wf.new("zoom.us"):subscribe(wf.windowCreated, function(newWin)
	u.closeBrowserTabsWith("zoom.us") -- remove leftover tabs

	-- close 2nd zoom window when joining a meeting
	if newWin:title() == "Zoom Meeting" then
		u.defer(1, function()
			local zoom = newWin:application()
			if not zoom or zoom:findWindow("Update") then return end
			local mainWin = zoom:findWindow("Zoom Workplace") or zoom:findWindow("Login")
			if mainWin then mainWin:close() end
		end)
	end
end)

--------------------------------------------------------------------------------
-- HIGHLIGHTS / PDF READER

-- - Sync Dark & Light Mode
-- - Start with Highlight Tool enabled
M.aw_highlights = aw.new(function(appName, event, app)
	if event == aw.launched and appName == "Highlights" then
		app:selectMenuItem { "View", "PDF Appearance", u.isDarkMode() and "Night" or "Default" }
		app:selectMenuItem { "Tools", "Highlight" }
		app:selectMenuItem { "Tools", "Color", "Yellow" }
		app:selectMenuItem { "View", "Hide Toolbar" }
	end
end):start()

--------------------------------------------------------------------------------
-- SCRIPT EDITOR

M.wf_scripteditor = wf
	.new("Script Editor")
	:subscribe(wf.windowCreated, function(newWin)
		-- skip new file creation dialog
		if newWin:title() == "Open" then
			hs.osascript.applescript('tell application "Script Editor" to make new document')

		-- resize window, paste, and format
		elseif newWin:title() == "Untitled" then
			wu.moveResize(newWin, wu.middleHalf)
			hs.eventtap.keyStroke({ "cmd" }, "v")
			hs.osascript.javascript('Application("Script Editor").documents()[0].checkSyntax()')

		-- if it's an AppleScript Dictionary, just resize window
		elseif newWin:title():find("%.sdef$") then
			wu.moveResize(newWin, wu.middleHalf)
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
-- TEXTEDIT
M.wf_textedit = wf.new("TextEdit"):subscribe(wf.windowCreated, function(newWin)
	-- skip new file creation dialog
	if newWin:title() == "Open" then
		hs.osascript.applescript('tell application "TextEdit" to make new document')

	-- resize window
	else
		wu.moveResize(newWin, wu.middleHalf)
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
		local narrow = { x = 0.184, y = 0, w = 0.45, h = 1 } -- for shorter line width
		local basesize = env.isProjector() and hs.layout.maximized or wu.pseudoMax
		local newSize = winCount > 1 and narrow or basesize
		wu.moveResize(newWin, newSize)
	end)

--------------------------------------------------------------------------------
return M
